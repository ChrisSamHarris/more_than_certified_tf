terraform {
  cloud {

    organization = "remote-mtc"

    workspaces {
      name = "ecs-terraform"
    }
  }
}