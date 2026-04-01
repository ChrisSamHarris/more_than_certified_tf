module "infra" {
  source      = "./modules/infra"
  vpc_cidr    = "10.0.0.0/16"
  num_subnets = 2
  allowed_ips = ["0.0.0.0/0"]
}

module "logic" {
  # changed to locals for better readability and maintainability
  # In order to prevent a destryo I moved the state 
  # terraform state mv 'module.logic' 'module.logic["primary_app"]'
  source = "./modules/logic"

  for_each           = local.application_configurations
  ecr_repo_name      = local.application_configurations[each.key].ecr_repo_name
  app_ui             = local.application_configurations[each.key].app_ui
  image_version      = local.application_configurations[each.key].image_version
  app_name           = local.application_configurations[each.key].app_name
  port               = local.application_configurations[each.key].port
  execution_role_arn = local.application_configurations[each.key].execution_role_arn
  cluster_arn        = local.application_configurations[each.key].cluster_arn
  subnets            = local.application_configurations[each.key].subnets
  ecs_app_sg_id      = local.application_configurations[each.key].ecs_app_sg_id
  is_public          = local.application_configurations[each.key].is_public
  vpc_id             = local.application_configurations[each.key].vpc_id
  path_pattern       = local.application_configurations[each.key].path_pattern
  alb_listener_arn   = local.application_configurations[each.key].alb_listener_arn
}