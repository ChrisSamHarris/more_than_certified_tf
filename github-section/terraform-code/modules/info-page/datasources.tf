data "github_user" "current" {
  username = ""
}

data "terraform_remote_state" "repos" {
  backend = "remote"

  config = {
    organization = "remote-mtc"
    workspaces = {
      name = "more_than_certified_tf"
    }
  }
}