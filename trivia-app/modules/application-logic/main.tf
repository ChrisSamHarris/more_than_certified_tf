data "aws_secretsmanager_secret" "api-key" {
  name = "OPENAI_API_KEY"
}

data "aws_secretsmanager_secret_version" "api-key" {
  secret_id = data.aws_secretsmanager_secret.api-key.id
}