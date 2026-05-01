output "openai-secret-v" {
  value     = module.logic["primary_app"].openai_secret_version
  sensitive = true
}

output "openai_secret" {
  value     = module.logic["primary_app"].openai_secret
}
