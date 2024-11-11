provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_caller_identity" "this" {}

variable "docker_auth_token" {
  type = string
}

module "test_gitlab_runner" {
  source            = "../"
  namespace         = "agn-ci"
  stage             = "dev"
  name              = "gitlab"
  vpc_cidr          = "10.88.128.0/20"
  subnets_cidr      = "10.88.128.0/24"
  docker_auth_token = var.docker_auth_token

  runner_ami_filter = {
    name = ["amazon-linux-2023-with-docker"]
  }
  runner_ami_owners = ["${data.aws_caller_identity.this.account_id}"]
  worker_ami_filter = {
    name = ["ubuntu-with-docker"]
  }
  worker_ami_owners = ["${data.aws_caller_identity.this.account_id}"]
  tags = {
    Test = "testing"
  }
}
