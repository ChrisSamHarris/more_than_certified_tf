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
    }
  }
  environments = toset(["dev", "staging"])
}