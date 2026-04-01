output "repo-info" {
  value = { for k, v in module.repos : k => v.repository_name_urls }
}

output "provisioner_status" {
  value       = var.run_provisioners ? "Provisioners are enabled." : "Provisioners are disabled."
  description = "Indicates whether provisioners are enabled or disabled."
  sensitive   = false
}