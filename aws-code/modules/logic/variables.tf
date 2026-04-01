variable "ecr_repo_name" {
  type    = string
  default = "mtc-ecs-repo"
}

variable "app_ui" {
  type    = string
  default = "ui"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "app_name" {
  type    = string
  default = "mtc-ecs-app"
}

variable "port" {
  type    = number
  default = 80
}

variable "execution_role_arn" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "ecs_app_sg_id" {
  type = list(string)
}

variable "is_public" {
  type    = bool
  default = true
}

variable "vpc_id" {
  type = string
}

variable "path_pattern" {
  type    = string
  default = "/*"
}

variable "alb_listener_arn" {
  type = string
}
