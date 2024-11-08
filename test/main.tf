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
  tags = {
    Test = "testing"
  }
}
