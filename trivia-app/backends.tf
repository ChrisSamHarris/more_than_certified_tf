terraform {
  backend "s3" {
    bucket       = "trivia-app-state-130426"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}