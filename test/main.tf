provider "aws" {
  region = "eu-central-1"
}
provider "gitlab" {
  token = var.gitlab_token
}

terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">= 17.7.1"
    }
  }
}

data "aws_caller_identity" "this" {}

data "aws_availability_zones" "this" {
  state = "available"
}


variable "docker_auth_token" {
  type = string
}

variable "gitlab_token" {
  type = string
}

variable "vpc_cidr" {
  default = "10.88.128.0/20"
  type    = string
}
variable "subnets_cidr" {
  default = "10.88.128.0/24"
  type    = string
}

locals {
  enabled                = true
  availability_zones     = sort(slice(data.aws_availability_zones.this.names, 0, 2))
  default_az             = local.availability_zones[0]
  vpc_id                 = module.vpc[0].vpc_id
  private_subnet_ids     = module.subnets[0].private_subnet_ids
  private_subnet_main_id = module.subnets[0].az_private_subnets_map[local.default_az][0]
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

module "test_gitlab_runner" {
  source            = "../"
  docker_auth_token = var.docker_auth_token
  vpc_id            = local.vpc_id
  subnet_id         = local.private_subnet_main_id
  subnet_ids        = local.private_subnet_ids

  runner_instances = {
    "aegean" = {
      untagged    = false
      tag_list    = ["aegean"]
      runner_type = "group_type"
      group_id    = 724805
    }
  }

  runner_ami_filter = {
    name = ["amazon-linux-2023-with-docker"]
  }
  runner_ami_owners = [data.aws_caller_identity.this.account_id]
  worker_ami_filter = {
    name = ["ubuntu-with-docker"]
  }
  worker_ami_owners = [data.aws_caller_identity.this.account_id]
}

output "vpc" {
  value = module.vpc
}

output "subnets" {
  value = module.subnets
}

output "runners" {
  value     = module.test_gitlab_runner
  sensitive = true
}
