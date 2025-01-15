#output "cache" {
#  value = module.runner_cache
#}

output "ssm_parameter_tokens" {
  value = aws_ssm_parameter.token
}

output "gitlab_user_runners" {
  value = gitlab_user_runner.instance
}

output "aws_runners" {
  value = module.runner
}
