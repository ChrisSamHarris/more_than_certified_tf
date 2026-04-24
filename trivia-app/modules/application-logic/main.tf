data "aws_secretsmanager_secret" "api-key" {
  name = "OPENAI_API_KEY"
}