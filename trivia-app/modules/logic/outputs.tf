output "gpt_secret_arn" {
  value = data.aws_secretsmanager_secret.api-key.arn
}

output "openai_secret" {
  value     = data.aws_secretsmanager_secret.api-key
}

output "openai_secret_version" {
  value     = data.aws_secretsmanager_secret_version.api-key
}