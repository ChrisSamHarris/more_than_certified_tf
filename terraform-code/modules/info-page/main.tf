resource "github_repository" "intro-repo" {
  name        = "introduction_repo"
  description = "This is a repository for the introduction index page"
  visibility  = "public"
  auto_init   = true
  pages {
    source {
      branch = "main"
      path   = "/"
    }
  }

  provisioner "local-exec" {
    command = var.run_provisioners ? "gh repo view ${self.name} --web" : "echo 'Provisioners are disabled. Set run_provisioners to true to enable.'"
  }
}

resource "time_static" "build-time" {
  # this datasource is used to capture the build time of the repository, which is then used in the index.md file to display the build date.
}

resource "github_repository_file" "index" {
  repository = github_repository.intro-repo.name
  content = templatefile("${path.module}/templates/index.tftpl", {
    avatar_url = data.github_user.current.avatar_url
    # date       = formatdate("YYYY", timestamp())
    date         = time_static.build-time.year
    name         = data.github_user.current.name
    username     = data.github_user.current.login
    repo_staging = local.repos["staging"]
    repo_dev     = local.repos["dev"]
  })
  file                = "index.md"
  branch              = "main"
  overwrite_on_create = true
}
