resource "random_id" "random" {
  byte_length = 2
  // The count parameter allows us to create multiple random IDs, which can be used to generate unique repository names.
  count = var.repo_count
}

resource "github_repository" "mtc_repo" {
  count       = var.repo_count
  name        = "mtc-repo-${random_id.random[count.index].id}"
  description = "This is a repository for the MTC Terraform code example"
  visibility  = "private"
  auto_init   = true
}

resource "github_repository_file" "readme" {
  // length function is used to determine the number of repositories created, and we create a README.md file for each repository.
  count               = var.repo_count
  repository          = github_repository.mtc_repo[count.index].name
  content             = "This repository is for infra developers. Environment: ${var.env}"
  file                = "README.md"
  branch              = "main"
  overwrite_on_create = true
}

resource "github_repository_file" "hello_file" {
  // length function is used again to create an index.html file for each repository, which includes a greeting and the random ID for uniqueness.
  // count.index is used to access the current index of the loop, allowing us to reference the correct repository and random ID for each file creation.
  count               = var.repo_count
  repository          = github_repository.mtc_repo[count.index].name
  content             = "Hello Terraform <br> Random ID Generation: ${random_id.random[count.index].dec} for ${github_repository.mtc_repo[count.index].name}"
  file                = "index.html"
  overwrite_on_create = true
  branch              = "main"
}

output "repository_names" {
  // splat operator (*) is used to extract the names of all repositories created by Terraform and return them as a list in the output. Think of a for loop that iterates over each repository and collects their names into a list.
  value       = github_repository.mtc_repo[*].name
  description = "GitHub Repository names created by Terraform"
  sensitive   = false
}

output "repository_urls" {
  value       = github_repository.mtc_repo[*].html_url
  description = "GitHub Repository URLs created by Terraform"
  # will still show as plaintext in the state file, even in terraform output -json
  sensitive = true
}

output "repository_name_urls" {
  # The for expression is used to create a map of repository names and their corresponding clone URLs. It iterates over each repository created by Terraform, using the splat operator to access the name and http_clone_url attributes, 
  # and constructs a key-value pair for each repository in the resulting map.
  value       = { for i in github_repository.mtc_repo[*] : i.name => i.http_clone_url }
  description = "GitHub Repository names and their corresponding clone URLs created by Terraform"
  sensitive   = false
}

output "environment" {
  value       = var.env
  description = "The environment for which the repositories were created"
  sensitive   = false
}