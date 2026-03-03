variable "repo_max_count" {
  description = "Number of repositories to create"
  type        = number
  default     = 3

  validation {
    condition     = var.repo_max_count <= 3
    error_message = "repo_max_count must be less than or equal to 3."
  }
}

variable "env" {
  type        = string
  description = "The environment for which to create the repositories (e.g., dev, staging, prod)"
  default     = "dev"

  validation {
    # condition     = var.env == "dev" || var.env == "staging" || var.env == "prod"
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of 'dev', 'staging', or 'prod'."
  }
}

variable "deployment_environments" {
  type        = map(map(string))
  description = "Set of environments for which to create the repositories"
  default = {
    dev = {
      lang     = "Terraform"
      filename = "main.tf"
    }
    staging = {
      lang     = "Python"
      filename = "main.py"
    }
    prod = {
      lang     = "Terraform"
      filename = "main.tf"
    }
  }

  validation {
    condition     = length(var.deployment_environments) > 0
    error_message = "Deployment environments list must contain at least one environment."
  }
  validation {
    condition     = alltrue([for env in keys(var.deployment_environments) : contains(["dev", "staging", "prod"], env)])
    error_message = "All deployment environments must be one of 'dev', 'staging', or 'prod'."
  }
  validation {
    condition     = length(var.deployment_environments) <= var.repo_max_count
    error_message = "The number of deployment environments must not exceed repo_max_count."
  }
}