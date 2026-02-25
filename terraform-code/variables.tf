variable "repo_count" {
  description = "Number of repositories to create"
  type        = number
  default     = 2

  validation {
    condition     = var.repo_count < 5
    error_message = "repo_count must be less than 5."
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
  type        = set(string)
  description = "Set of environments for which to create the repositories"
  default     = ["dev", "staging", "prod"]

  validation {
    condition     = length(var.deployment_environments) > 0
    error_message = "Deployment environments list must contain at least one environment."
  }
  validation {
    condition     = alltrue([for env in var.deployment_environments : contains(["dev", "staging", "prod"], env)])
    error_message = "All deployment environments must be one of 'dev', 'staging', or 'prod'."
  }
}