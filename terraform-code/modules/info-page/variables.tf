variable "repo_staging" {
  type = map(any)
}

variable "repo_dev" {
  type = map(any)
}

variable "run_provisioners" {
  type    = bool
  default = true
}
