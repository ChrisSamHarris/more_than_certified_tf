variable "environments" {
  type    = set(string)
  default = ["dev", "staging"]
}

variable "run_provisioners" {
  type    = bool
  default = false
}