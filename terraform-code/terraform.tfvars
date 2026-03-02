repo_max_count = 3
env            = "dev"

deployment_environments = {
  dev = {
    lang     = "terraform",
    filename = "main.tf"
  },
  staging = {
    lang     = "python",
    filename = "main.py"
  },
  prod = {
    lang     = "terraform",
    filename = "main.tf"
  }
}