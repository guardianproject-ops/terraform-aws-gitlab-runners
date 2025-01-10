locals {
  enabled                = module.this.enabled
  availability_zones     = sort(slice(data.aws_availability_zones.this.names, 0, 2))
  default_az             = local.availability_zones[0]
  vpc_id                 = module.vpc[0].vpc_id
  private_subnet_ids     = module.subnets[0].private_subnet_ids
  private_subnet_main_id = module.subnets[0].az_private_subnets_map[local.default_az][0]
}
data "aws_availability_zones" "this" {
  state = "available"
}

module "vpc" {
  source                           = "cloudposse/vpc/aws"
  version                          = "2.2.0"
  count                            = local.enabled ? 1 : 0
  ipv4_primary_cidr_block          = var.vpc_cidr
  assign_generated_ipv6_cidr_block = false
  context                          = module.this.context
  attributes                       = ["vpc"]
}

module "subnets" {
  source                          = "cloudposse/dynamic-subnets/aws"
  version                         = "2.4.2"
  count                           = local.enabled ? 1 : 0
  max_subnet_count                = 2
  availability_zones              = local.availability_zones
  vpc_id                          = local.vpc_id
  igw_id                          = [module.vpc[0].igw_id]
  ipv4_cidr_block                 = [var.subnets_cidr]
  ipv6_enabled                    = false
  ipv4_enabled                    = true
  public_subnets_additional_tags  = { "Visibility" : "Public" }
  private_subnets_additional_tags = { "Visibility" : "Private" }
  metadata_http_endpoint_enabled  = true
  metadata_http_tokens_required   = true
  public_subnets_enabled          = true
  context                         = module.this.context
  attributes                      = ["vpc", "subnet"]
}

locals {
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

}

module "runner" {
  source  = "cattle-ops/gitlab-runner/aws"
  version = "8.1.0"

  environment       = module.this.id
  iam_object_prefix = module.this.id
  vpc_id            = local.vpc_id
  subnet_id         = local.private_subnet_main_id

  runner_gitlab = {
    tag_list                                      = "runner_worker"
    type                                          = "instance"
    url                                           = "https://gitlab.com"
    runner_version                                = "17.7.0" # ref: https://gitlab.com/gitlab-org/gitlab-runner/-/releases
    preregistered_runner_token_ssm_parameter_name = "${module.this.id}-runner-token"
  }

  runner_ami_filter                          = var.runner_ami_filter
  runner_ami_owners                          = var.runner_ami_owners
  runner_worker_docker_autoscaler_ami_filter = var.worker_ami_filter
  runner_worker_docker_autoscaler_ami_owners = var.worker_ami_owners

  runner_role = {
    additional_tags = module.this.tags
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
    additional_tags = module.this.tags
  }

  runner_worker_docker_machine_role = {
    additional_tags = module.this.tags
  }

  runner_manager = {
    maximum_concurrent_jobs = 5
  }

  runner_instance = {
    collect_autoscaling_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity"]
    name                        = "${module.this.id}-instance"
    ssm_access                  = true
    type                        = "t3.small"
    additional_tags             = module.this.tags
  }

  runner_worker = {
    max_jobs            = 10 # this is the maximum number of auto-scaled instances
    request_concurrency = 5
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
    start_script  = file("${path.module}/worker_start.sh")
    root_size     = 100
    volume_type   = "gp3"
    ebs_optimized = true
  }

  runner_worker_docker_autoscaler_asg = {
    on_demand_base_capacity                  = 0
    on_demand_percentage_above_base_capacity = 0
    enable_mixed_instances_policy            = true
    idle_time                                = 600
    subnet_ids                               = local.private_subnet_ids
    types                                    = ["t3a.medium", "t3.medium"]
    volume_type                              = "gp3"
    private_address_only                     = true
    ebs_optimized                            = true
    root_size                                = 100
  }

  runner_worker_docker_autoscaler = {
    connector_config_user = "ubuntu"
    # fleeting_plugin_version = "1.0.0" # ref: https://gitlab.com/gitlab-org/fleeting/plugins/aws/-/releases
  }
}
