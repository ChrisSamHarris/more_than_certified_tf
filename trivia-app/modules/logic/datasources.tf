data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.logic-ecr.registry_id
}

data "aws_secretsmanager_secret" "api-key" {
  name = "OPENAI_API_KEY"
}

data "aws_secretsmanager_secret_version" "api-key" {
  secret_id = data.aws_secretsmanager_secret.api-key.id
}