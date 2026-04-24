output "secret_api_key" {
  value = data.aws_secretsmanager_secret.api-key
}