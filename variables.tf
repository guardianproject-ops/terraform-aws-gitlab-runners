variable "docker_auth_token" {
  type        = string
  default     = ""
  description = "A docker.io auth token (optional)"
  sensitive   = true
}

variable "runner_ami_owners" {
  description = "The list of owners used to select the AMI of the Runner instance."
  type        = list(string)
  default     = ["amazon"]
}

variable "runner_ami_filter" {
  description = "List of maps used to create the AMI filter for the Runner AMI. Must resolve to an Amazon Linux 1, 2 or 2023 image."
  type        = map(list(string))

  default = {
    name = ["al2023-ami-2023*-x86_64"]
  }
}

variable "worker_ami_filter" {
  description = "List of maps used to create the AMI filter for the Worker AMI. Should be Ubuntu"
  type        = map(list(string))

  default = {
    name = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

variable "worker_ami_owners" {
  type    = list(string)
  default = ["099720109477"] # ubuntu
}

variable "runner_version" {
  description = "Gitlab runner version"
  type        = string
  default     = "17.7.0" # renovate: packageName=gitlab-org/gitlab-runner
}

variable "fleeting_plugin_version" {
  description = "Gitlab runner version"
  type        = string
  default     = "1.0.0" # renovate: packageName=gitlab-org/fleeting/plugins/aws
}

variable "runner_instances" {
  type = map(object({
    untagged                = bool
    runner_type             = string # project_type, group_type, instance_type
    tag_list                = optional(list(string))
    access_level            = optional(string, "not_protected") # not_protected, ref_protected
    maintenance_note        = optional(string)
    group_id                = optional(number)
    project_id              = optional(number)
    maximum_timeout         = optional(number)
    paused                  = optional(bool)
    description             = optional(string)
    maximum_concurrent_jobs = optional(number, 5)
    runner_instance_type    = optional(string, "t3.small")
    worker_instance_types   = optional(list(string), ["t3a.medium", "t3.medium"])
    autoscaling_options = optional(list(object({
      periods            = list(string)
      timezone           = optional(string, "UTC")
      idle_count         = optional(number)
      idle_time          = optional(string)
      scale_factor       = optional(number)
      scale_factor_limit = optional(number, 0)
      })),
      [
        {
          periods      = ["* * * * *"]
          timezone     = "Europe/Berlin"
          idle_count   = 0
          idle_time    = "30m"
          scale_factor = 2
        },
        {
          periods      = ["* 7-19 * * mon-fri"]
          timezone     = "Europe/Berlin"
          idle_count   = 2
          idle_time    = "30m"
          scale_factor = 2
        }

    ])
  }))
}

variable "kms_key_id" {
  description = "KMS key id to encrypted the resources. Ensure that your Runner/Executor has access to the KMS key."
  type        = string
  default     = ""
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = <<-EOT
    Subnet id used for the Runner and Runner Workers. Must belong to the `vpc_id`. In case the fleet mode is used, multiple subnets for
    the Runner Workers can be provided with runner_worker_docker_machine_instance.subnet_ids.
  EOT
}

variable "subnet_ids" {
  type        = list(string)
  description = <<-EOT
The list of subnet IDs to use for the Runner Worker when the fleet mode is enabled.
EOT
}

variable "tailscale_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
Set to true to connect the worker and runner agent to tailscale.
EOT
}

variable "tailscale_tags_runner" {
  type    = list(string)
  default = []

  description = "The list of tags that will be assigned to tailscale node created by this stack."
  validation {
    condition = alltrue([
      for tag in var.tailscale_tags_runner : can(regex("^tag:", tag))
    ])
    error_message = "max_allocated_storage: Each tag in tailscale_tags_runner must start with 'tag:'"
  }

  validation {
    condition     = var.tailscale_enabled ? var.tailscale_tags_runner != null : true
    error_message = "If tailscale_enabled is true, then you must set tailscale_tags_runner"
  }
}

variable "tailscale_tailnet" {
  type    = string
  default = null

  description = <<EOT
  description = The tailnet domain (or "organization's domain") for your tailscale tailnet, this s found under Settings > General > Organization
EOT

  validation {
    condition     = var.tailscale_enabled ? var.tailscale_tailnet != null : true
    error_message = "If tailscale_enabled is true, then you must set tailscale_tailnet"
  }
}

variable "tailscale_client_id_runner" {
  type        = string
  default     = null
  sensitive   = true
  description = "The OIDC client id for tailscale that has permissions to create auth keys with the `tailscale_tags_runner` tags"

  validation {
    condition     = var.tailscale_enabled ? var.tailscale_client_id_runner != null : true
    error_message = "If tailscale_enabled is true, then you must set tailscale_client_id_runner"
  }
}

variable "tailscale_client_secret_runner" {
  type        = string
  default     = null
  sensitive   = true
  description = "The OIDC client secret paired with `tailscale_client_id_runner`"

  validation {
    condition     = var.tailscale_enabled ? var.tailscale_client_secret_runner != null : true
    error_message = "If tailscale_enabled is true, then you must set tailscale_client_secret_runner"
  }
}
