repo_max_count = 3
env            = "dev"

deployment_environments = {
  dev = {
    lang     = "Terraform",
    filename = "main.tf"
    pages    = true
  },
  staging = {
    lang     = "Python",
    filename = "main.py"
    pages    = false
  },
  prod = {
    lang     = "Terraform",
    filename = "main.tf"
    pages    = false
  }
}