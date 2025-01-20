locals {
  capacity_per_instance = 1
  DOCKER_AUTH_CONFIG = jsonencode({
    auths = {
      "https://index.docker.io/v1/" = {
        auth = var.docker_auth_token
      }
    }
    #credHelpers = {
    #  "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-west-2.amazonaws.com" = "ecr-login"
    #}
  })


  authkey_runner_secretsmanager_arn = var.tailscale_enabled ? aws_secretsmanager_secret.authkey_runner[0].arn : ""

  _tailscale_bootstrap_script = <<-EOT
mkdir -p /etc/systemd/system/tailscale-connect.service.d
cat > /etc/systemd/system/tailscale-connect.service.d/override.conf << EOF
[Service]
Environment="TS_HOSTNAME=@@HOSTNAME@@"
Environment="TS_SECRET_ARN=${local.authkey_runner_secretsmanager_arn}"
Environment="TS_EXTRA_ARGS=--ssh"
EOF

systemctl daemon-reload
systemctl enable --now tailscaled tailscale-connect
EOT

  tailscale_bootstrap_script = var.tailscale_enabled ? local._tailscale_bootstrap_script : ""

  runner_pre_install_script = <<-EOT
tee /etc/hosts <<EOL
127.0.0.1   localhost localhost.localdomain @@HOSTNAME@@
EOL
${local.tailscale_bootstrap_script}
EOT

  worker_start_script = <<-EOT
systemctl enable --now docker
EOT
}

module "cache" {
  source                               = "cattle-ops/gitlab-runner/aws//modules/cache"
  version                              = "8.1.0"
  environment                          = module.this.id
  cache_bucket_name_include_account_id = false
  cache_bucket_versioning              = true
  cache_expiration_days                = 7
  cache_lifecycle_clear                = true
  kms_key_id                           = var.kms_key_id
}

module "instance_label" {
  for_each   = var.runner_instances
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = [each.key]
}

resource "gitlab_user_runner" "instance" {
  for_each = var.runner_instances

  runner_type      = each.value.runner_type
  project_id       = each.value.project_id
  group_id         = each.value.group_id
  description      = each.value.description != null ? each.value.description : "Managed by terraform @ ${module.instance_label[each.key].id}"
  untagged         = each.value.untagged
  tag_list         = each.value.tag_list
  access_level     = each.value.access_level
  maintenance_note = each.value.maintenance_note
  maximum_timeout  = each.value.maximum_timeout
  paused           = each.value.paused
}

resource "aws_ssm_parameter" "token" {
  for_each = var.runner_instances
  name     = "${module.instance_label[each.key].id}-auth-token"
  key_id   = var.kms_key_id
  type     = "SecureString"
  value    = gitlab_user_runner.instance[each.key].token
  tags     = module.instance_label[each.key].tags
}

data "aws_iam_policy_document" "runner_secrets" {
  count = var.tailscale_enabled ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [local.authkey_runner_secretsmanager_arn]
  }
}

resource "aws_iam_policy" "gitlab_runner_secrets" {
  count  = var.tailscale_enabled ? 1 : 0
  name   = "${module.this.id}-runner-secrets"
  tags   = module.this.tags
  policy = data.aws_iam_policy_document.runner_secrets[0].json
}

module "runner" {
  for_each = var.runner_instances
  source   = "cattle-ops/gitlab-runner/aws"
  version  = "8.1.0"

  environment       = module.instance_label[each.key].id
  iam_object_prefix = module.instance_label[each.key].id
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id

  runner_gitlab = {
    tag_list                                      = "runner_worker"
    type                                          = "instance"
    url                                           = "https://gitlab.com"
    runner_version                                = var.runner_version
    preregistered_runner_token_ssm_parameter_name = aws_ssm_parameter.token[each.key].name
  }

  runner_ami_filter                          = var.runner_ami_filter
  runner_ami_owners                          = var.runner_ami_owners
  runner_worker_docker_autoscaler_ami_filter = var.worker_ami_filter
  runner_worker_docker_autoscaler_ami_owners = var.worker_ami_owners

  runner_role = {
    additional_tags = module.instance_label[each.key].tags
    policy_arns = var.tailscale_enabled ? [
      aws_iam_policy.gitlab_runner_secrets[0].arn
    ] : []
  }

  # This one is definitely required for DIND
  runner_worker_docker_add_dind_volumes = true

  # these, I think not.
  #runner_worker_docker_options = {
  #  privileged = "true" # this one is scary
  #  volumes    = ["/cache", "/certs/client"]
  #}

  #runner_worker_docker_volumes_tmpfs = [
  #  {
  #    volume  = "/var/opt/cache",
  #    options = "rw,noexec"
  #  }
  #]

  runner_worker_docker_autoscaler_role = {
    additional_tags = module.instance_label[each.key].tags
  }

  runner_worker_docker_machine_role = {
    additional_tags = module.instance_label[each.key].tags
  }

  runner_manager = {
    maximum_concurrent_jobs   = local.capacity_per_instance * each.value.maximum_concurrent_jobs
    prometheus_listen_address = var.tailscale_enabled ? ":9252" : ""
  }

  runner_install = {
    pre_install_script = replace(
      local.runner_pre_install_script,
      "@@HOSTNAME@@",
      "${module.instance_label[each.key].id}-runner"
    )
  }

  runner_instance = {
    collect_autoscaling_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity"]
    name                        = "${module.instance_label[each.key].id}-instance"
    name_prefix                 = "${module.instance_label[each.key].id}-instance"
    ssm_access                  = true
    type                        = each.value.runner_instance_type
    additional_tags             = module.instance_label[each.key].tags
    use_eip                     = false
  }

  runner_worker = {
    max_jobs            = each.value.maximum_concurrent_jobs # this is the maximum number of auto-scaled instances
    request_concurrency = 1
    type                = "docker-autoscaler"
    ssm_access          = true
    environment_variables = compact([
      #"AWS_REGION=${local.region}",
      #"AWS_SDK_LOAD_CONFIG=true",
      var.docker_auth_token != "" ?
      "DOCKER_AUTH_CONFIG=${local.DOCKER_AUTH_CONFIG}" : null
    ])
  }

  runner_worker_docker_autoscaler_instance = {
    start_script = replace(
      local.worker_start_script,
      "@@HOSTNAME@@",
      "${module.instance_label[each.key].id}-worker"
    )
    root_size             = 100
    volume_type           = "gp3"
    ebs_optimized         = true
    capacity_per_instance = local.capacity_per_instance
  }

  runner_worker_docker_autoscaler_asg = {
    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    max_growth_rate                          = 10
    enable_mixed_instances_policy            = true
    idle_time                                = 600
    subnet_ids                               = var.subnet_ids
    types                                    = each.value.worker_instance_types
    volume_type                              = "gp3"
    private_address_only                     = true
    ebs_optimized                            = true
    root_size                                = 100
    spot_allocation_strategy                 = "lowest-price"
  }

  runner_worker_docker_autoscaler = {
    connector_config_user   = "ubuntu"
    fleeting_plugin_version = var.fleeting_plugin_version
    max_use_count           = 1 # each instance is used for only one ci job
  }

  runner_worker_docker_autoscaler_autoscaling_options = each.value.autoscaling_options

  runner_worker_cache = {
    create = false
    shared = true
    bucket = module.cache.bucket
  }

  tags = module.instance_label[each.key].tags
}

resource "aws_iam_role_policy_attachment" "cache_bucket_access" {
  for_each   = var.runner_instances
  role       = module.runner[each.key].runner_agent_role_name
  policy_arn = module.cache.policy_arn
}
