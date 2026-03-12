output "info_repo_pages_link" {
  value       = try(github_repository.intro-repo.pages[0].html_url, "No pages link found.")
  description = "The GitHub Pages link for intro-repository."
  sensitive   = false
}