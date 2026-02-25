resource "random_id" "random" {
  byte_length = 4
  for_each    = var.deployment_environments
}

resource "github_repository" "mtc_repo" {
  # reminder: count causes issues in state modification and removals; indexed list | for_each is a better option for dynamic resource creation and management.
  # count = var.repo_count
  for_each    = var.deployment_environments
  name        = "mtc-repo-${each.key}"
  description = "${each.key} variable | This is a repository for the MTC Terraform code example"
  visibility  = each.key == "dev" ? "public" : "private"
  auto_init   = true
}

resource "github_repository_file" "readme" {
  // length function is used to determine the number of repositories created, and we create a README.md file for each repository.
  for_each            = var.deployment_environments
  repository          = github_repository.mtc_repo[each.key].name
  content             = "This repository is for infra developers. Environment: ${var.env}"
  file                = "README.md"
  branch              = "main"
  overwrite_on_create = true
}

resource "github_repository_file" "hello_file" {
  // length function is used again to create an index.html file for each repository, which includes a greeting and the random ID for uniqueness.
  // count.index is used to access the current index of the loop, allowing us to reference the correct repository and random ID for each file creation.
  for_each            = var.deployment_environments
  repository          = github_repository.mtc_repo[each.key].name
  content             = "Hello Terraform <br> Random ID Generation: ${random_id.random[each.key].hex} for ${github_repository.mtc_repo[each.key].name}"
  file                = "index.html"
  overwrite_on_create = true
  branch              = "main"
}

output "repository_name_urls" {
  # The for expression is used to create a map of repository names and their corresponding clone URLs. It iterates over each repository created by Terraform, using the splat operator to access the name and http_clone_url attributes, 
  # and constructs a key-value pair for each repository in the resulting map.
  value       = { for i in values(github_repository.mtc_repo) : i.name => i.http_clone_url }
  description = "GitHub Repository names and their corresponding clone URLs created by Terraform"
  sensitive   = false
}
