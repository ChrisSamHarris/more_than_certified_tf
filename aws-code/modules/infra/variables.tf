variable "vpc_cidr" {
  type = string
}

variable "num_subnets" {
  type    = number
  default = 2
  validation {
    condition     = var.num_subnets > 0 ? true : false
    error_message = "num_subnets must be a positive integer, greater than 0."
  }
}

variable "allowed_ips" {
  type = set(string)
}