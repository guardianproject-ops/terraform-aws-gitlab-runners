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
