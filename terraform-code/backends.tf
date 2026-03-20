# terraform {
#   backend "local" {
#     path = "../state/terraform.tfstate"
#   }
# }

terraform {
  cloud {
    organization = "remote-mtc"

    workspaces {
      name = "dev"
    }
  }
}