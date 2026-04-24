module "infra" {
  source      = "./modules/infrastructure"
  vpc_cidr    = local.infrastructure_configurations.vpc_cidr
}

module "application-logic" {
  source = "./modules/application-logic"
}