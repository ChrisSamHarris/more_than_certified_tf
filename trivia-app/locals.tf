locals {
  application_configurations = {
    primary_app = {
      ecr_repo_name      = "mtc-ecs-repo",
      app_ui             = "ui",
      image_version      = "1.0.0",
      app_name           = "mtc-ecs-app",
      port               = 80,
      execution_role_arn = module.infra.execution-role-arn,
      cluster_arn        = module.infra.aws-ecs-cluster,
      subnets            = module.infra.mtc-subnets,
      ecs_app_sg_id      = [module.infra.ecs-app-sg],
      is_public          = true,
      vpc_id             = module.infra.vpc-id,
      path_pattern       = "/*",
      alb_listener_arn   = module.infra.alb_listener_arn
    },
  }
}