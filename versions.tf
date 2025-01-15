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
