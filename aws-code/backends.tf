# terraform {
#   cloud {

#     organization = "remote-mtc"

#     workspaces {
#       name = "ecs-terraform"
#     }
#   }
# }

#  1050  terraform state pull > terraform.tfstate
#  saved state to freshly provisioned S3 bucket
#  1051  terraform init -reconfigure
#  1052  terraform state list

terraform {
  backend "s3" {
    bucket       = "mtc-app-state-010426"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}