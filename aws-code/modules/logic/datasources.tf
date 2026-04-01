data "aws_ecr_authorization_token" "token" {
  registry_id = aws_ecr_repository.logic-ecr.registry_id
}