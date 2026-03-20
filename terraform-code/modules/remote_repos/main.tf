
resource "local_file" "repos" {
  content  = jsonencode(local.deployment_repositories)
  filename = "${path.module}/graphs/repos.json"
}

module "repos" {
  source                  = "./modules/repositories"
  for_each                = var.environments
  repo_max_count          = 9
  env                     = each.key
  deployment_environments = local.deployment_repositories
  run_provisioners        = var.run_provisioners
}
