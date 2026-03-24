locals {
  deployment_repositories = {
    infra = {
      lang     = "Terraform",
      filename = "main.tf"
      pages    = true
    },
    data-science = {
      lang     = "Python",
      filename = "main.py"
      pages    = false
    },
    frontend = {
      lang     = "JavaScript",
      filename = "app.js"
      pages    = false
    }
  }

  repos = { for k, v in data.terraform_remote_state.repos.outputs.repo-info : k => v }
}
