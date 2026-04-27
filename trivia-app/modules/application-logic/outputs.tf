output "secret_api_key" {
  value = data.aws_secretsmanager_secret.api-key
}

output "api_key_value" {
  value = jsondecode(data.aws_secretsmanager_secret_version.api-key.secret_string)["OPENAI_API_KEY"]
}