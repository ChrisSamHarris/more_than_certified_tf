output "repo-info" {
  value = { for k, v in module.repos : k => v.repository_name_urls }
}

# output "repo_intro_pages_link" {
#   value       = module.info_page.info_repo_pages_link
#   description = "The GitHub Pages link for the intro repository."
#   sensitive   = false
# }

output "provisioner_status" {
  value       = var.run_provisioners ? "Provisioners are enabled." : "Provisioners are disabled."
  description = "Indicates whether provisioners are enabled or disabled."
  sensitive   = false
}

# output "repo_list_staging" {
#   value = flatten([for k, v in module.repositories : keys(v.repository_name_urls) if k == "staging"])
# }

# output "repo_list_dev" {
#   value = flatten([for k, v in module.repositories : keys(v.repository_name_urls) if k == "dev"])
# }