locals {
  ecr_url   = aws_ecr_repository.logic-ecr.repository_url
  ecr_token = data.aws_ecr_authorization_token.token
}
