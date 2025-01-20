module "label_rotate_runner" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.this.context
  attributes = ["runner", "rotate"]
  enabled    = var.tailscale_enabled
}

#############################################################################
# Tailscale Auth key
resource "aws_secretsmanager_secret" "authkey_runner" {
  count                   = module.label_rotate_runner.enabled ? 1 : 0
  name                    = "${module.label_rotate_runner.id}/tailscale_auth_key"
  recovery_window_in_days = 0
  tags                    = module.label_rotate_runner.tags
}

resource "aws_secretsmanager_secret_rotation" "authkey_runner" {
  count               = module.label_rotate_runner.enabled ? 1 : 0
  secret_id           = aws_secretsmanager_secret.authkey_runner[0].id
  rotation_lambda_arn = module.ts_rotate_runner.lambda.lambda_function_arn

  rotation_rules {
    automatically_after_days = 3
  }
}

resource "aws_secretsmanager_secret_version" "authkey_runner" {
  count     = module.label_rotate_runner.enabled ? 1 : 0
  secret_id = aws_secretsmanager_secret.authkey_runner[0].id
  secret_string = jsonencode({
    "Type" : "auth-key",
    "Attributes" : {
      "key_request" : {
        "tags" : var.tailscale_tags_runner,
        "description" : "Auth key for ${module.label_rotate_runner.id} runner",
        # 3 days + 6 hours = so it is valid slightly longer than the secret in secrets manager
        "expiry_seconds" : (3 * 24 * 60 * 60) + 6 * 60 * 60,
        "reusable" : true,
        "ephemeral" : true
      }
  } })
  version_stages = ["TFINIT"]
  depends_on = [
    module.ts_rotate_runner.lambda
  ]
}

#############################################################################
# Rotation Lambda
module "ts_rotate_runner" {
  source           = "guardianproject-ops/lambda-secrets-manager-tailscale/aws"
  version          = "0.0.2"
  enabled          = module.label_rotate_runner.enabled
  ts_client_secret = var.tailscale_client_secret_runner
  ts_client_id     = var.tailscale_client_id_runner
  tailnet          = var.tailscale_tailnet
  secret_prefix    = "${module.label_rotate_runner.id}/*"
  context          = module.label_rotate_runner.context
}
