resource "random_id" "random" {
  byte_length = 4
  for_each    = var.deployment_environments
}

resource "github_repository" "mtc_repo" {
  # reminder: count causes issues in state modification and removals; indexed list | for_each is a better option for dynamic resource creation and management.
  # count = var.repo_count
  for_each    = var.deployment_environments
  name        = "mtc-${each.key}-${var.env}"
  description = "${each.key} | This is a repository for the MTC Terraform code example | Language: ${each.value.lang}"
  visibility  = var.env == "dev" ? "public" : "private"
  auto_init   = true
  dynamic "pages" {
    for_each = each.value.pages == true && var.env == "dev" ? [1] : []
    content {
      build_type = "legacy"
      source {
        branch = "main"
        path   = "/"
      }
    }
  }

  provisioner "local-exec" {
    # only open the browser for the dev environment, as it's public; for staging and prod, we skip opening the browser since they are private repositories.
    command = var.run_provisioners && each.key == "dev" ? "gh repo view ${self.name} --web" : "echo 'Skipping browser open for ${each.key} environment'"
  }
  provisioner "local-exec" {
    # circular dependency so it won't accept a dependency on a potentially deleted variable - as such, no dependency on var.run_provisioners required
    command = "rm -rf ${self.name}"
    when    = destroy
  }
}

resource "terraform_data" "repo-clone" {
  for_each   = var.deployment_environments
  depends_on = [github_repository_file.readme, github_repository_file.main]

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo clone ${github_repository.mtc_repo[each.key].name}" : "echo 'Skipping repository clone for ${github_repository.mtc_repo[each.key].name}'"
  }
}

resource "github_repository_file" "readme" {
  # length function is used to determine the number of repositories created, and we create a README.md file for each repository.
  for_each   = var.deployment_environments
  repository = github_repository.mtc_repo[each.key].name
  content = templatefile("${path.module}/templates/readme.tftpl", {
    lang        = each.value.lang
    environment = each.key
    username    = data.github_user.current.login
  })
  # content             = <<-EOT
  # # This repository is for ${each.value.lang} developers.
  # ### Environment: ${each.key}
  # Created by: ${data.github_user.current.login}
  # EOT
  file                = "README.md"
  branch              = "main"
  overwrite_on_create = true
}

resource "github_repository_file" "main" {
  # length function is used again to create an index.html file for each repository, which includes a greeting and the random ID for uniqueness.
  # count.index is used to access the current index of the loop, allowing us to reference the correct repository and random ID for each file creation.
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

# moved is used to rename the resource github_repository_file.hello_file to github_repository_file.main, which allows us to maintain the same resource configuration while changing its name for better clarity and organization in our Terraform code.
# Great for documentation and stops the resource from being destroyed and recreated.
# moved {
#   from = github_repository_file.hello_file
#   to   = github_repository_file.main
# }

