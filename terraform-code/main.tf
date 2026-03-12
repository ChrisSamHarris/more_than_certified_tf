module "repos" {
  source                  = "./modules/repositories"
  for_each                = local.environments
  repo_max_count          = 9
  env                     = each.key
  deployment_environments = local.deployment_repositories
}

module "info_page" {
  source       = "./modules/info-page"
  repo_staging = module.repos["staging"].repository_name_urls
  repo_dev     = module.repos["dev"].repository_name_urls
}