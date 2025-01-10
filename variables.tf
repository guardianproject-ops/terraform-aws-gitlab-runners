variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "subnets_cidr" {
  type        = string
  description = "CIDR block for the subnets"
}

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
  default = ["099720109477"]
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
