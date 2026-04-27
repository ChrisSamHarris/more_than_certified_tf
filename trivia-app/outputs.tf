output "openai_secret_api_key" {
  value = module.application-logic.secret_api_key
}

output "openai_api_key" {
  value     = module.application-logic.api_key_value
  sensitive = true
}