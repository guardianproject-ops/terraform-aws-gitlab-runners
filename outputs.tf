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

output "secrets_manager_secret_authkey_arn_runner" {
  value = var.tailscale_enabled ? aws_secretsmanager_secret.authkey_runner[0].arn : ""
}

output "secrets_manager_secret_authkey_id_runner" {
  value = var.tailscale_enabled ? aws_secretsmanager_secret.authkey_runner[0].id : ""
}
