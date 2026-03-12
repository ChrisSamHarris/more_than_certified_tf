output "repository_name_urls" {
  # The for expression is used to create a map of repository names and their corresponding clone URLs. It iterates over each repository created by Terraform, using the splat operator to access the name and http_clone_url attributes, 
  # and constructs a key-value pair for each repository in the resulting map.
  value       = { for i in values(github_repository.mtc_repo) : i.name => { "SSH-URL" : i.ssh_clone_url, "Repo-URL" : i.http_clone_url, "GH-Pages-URL" : coalesce(try(i.pages[0].html_url, ""), "No GH Pages configured") } }
  description = "GitHub Repository names and their corresponding clone URLs created by Terraform"
  sensitive   = false
}

output "github_username" {
  # coalescence function is used to provide a fallback valLue in case the data source fails to retrieve the GitHub username. If data.github_user.current.login is null or empty, it will return "Unknown User" instead, ensuring that the output always has a meaningful value.
  value       = coalesce(data.github_user.current.login, "Unknown User")
  description = "The GitHub username of the authenticated user, which is used in the content of the README.md file for each repository to indicate who created the repository."
  sensitive   = false
}

output "github_pages_link_public" {
  value       = try(github_repository.mtc_repo["infra"].pages[0].html_url, "No pages configured for infra repo.")
  description = "The GitHub Pages link for the public dev repository."
  sensitive   = false
}
