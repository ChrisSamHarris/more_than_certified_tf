resource "random_id" "random" {
  byte_length = 4
  for_each    = var.deployment_environments
}

data "github_user" "current" {
  username = ""
}

resource "github_repository" "mtc_repo" {
  # reminder: count causes issues in state modification and removals; indexed list | for_each is a better option for dynamic resource creation and management.
  # count = var.repo_count
  for_each    = var.deployment_environments
  name        = "mtc-repo-${each.key}"
  description = "${each.key} | This is a repository for the MTC Terraform code example | Language: ${each.value.lang}"
  visibility  = each.key == "dev" ? "public" : "private"
  auto_init   = true
  provisioner "local-exec" {
    # only open the browser for the dev environment, as it's public; for staging and prod, we skip opening the browser since they are private repositories.
    command = each.key == "dev" ? "gh repo view ${self.name} --web" : "echo 'Skipping browser open for ${each.key} environment'"
  }
  provisioner "local-exec" {
    command = "rm -rf ${self.name}"
    when    = destroy
  }
}

resource "terraform_data" "repo-clone" {
  for_each   = var.deployment_environments
  depends_on = [github_repository_file.readme, github_repository_file.hello_file]

  provisioner "local-exec" {
    command = "gh repo clone ${github_repository.mtc_repo[each.key].name}"
  }
}

resource "github_repository_file" "readme" {
  // length function is used to determine the number of repositories created, and we create a README.md file for each repository.
  for_each            = var.deployment_environments
  repository          = github_repository.mtc_repo[each.key].name
  content             = "Created by ${data.github_user.current.login} (${data.github_user.current.name}) | This repository is for ${each.value.lang} developers. Environment: ${each.key}"
  file                = "README.md"
  branch              = "main"
  overwrite_on_create = true
  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "github_repository_file" "hello_file" {
  // length function is used again to create an index.html file for each repository, which includes a greeting and the random ID for uniqueness.
  // count.index is used to access the current index of the loop, allowing us to reference the correct repository and random ID for each file creation.
  for_each            = var.deployment_environments
  repository          = github_repository.mtc_repo[each.key].name
  content             = "Chosen language of choice: ${each.value.lang} | Random ID Generation: ${random_id.random[each.key].hex} for ${github_repository.mtc_repo[each.key].name}"
  file                = each.value.filename
  overwrite_on_create = true
  branch              = "main"
  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

output "repository_name_urls" {
  # The for expression is used to create a map of repository names and their corresponding clone URLs. It iterates over each repository created by Terraform, using the splat operator to access the name and http_clone_url attributes, 
  # and constructs a key-value pair for each repository in the resulting map.
  value       = { for i in values(github_repository.mtc_repo) : i.name => { "SSH URL" : i.ssh_clone_url, "URL" : i.http_clone_url } }
  description = "GitHub Repository names and their corresponding clone URLs created by Terraform"
  sensitive   = false
}

output "github_username" {
  # coalescence function is used to provide a fallback value in case the data source fails to retrieve the GitHub username. If data.github_user.current.login is null or empty, it will return "Unknown User" instead, ensuring that the output always has a meaningful value.
  value = coalesce(data.github_user.current.login, "Unknown User")
  description = "The GitHub username of the authenticated user, which is used in the content of the README.md file for each repository to indicate who created the repository."
  sensitive   = false
}
