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
    command = "gh repo view ${self.name} --web"
  }
}

resource "time_static" "build-time" {
  # this datasource is used to capture the build time of the repository, which is then used in the index.md file to display the build date.
}

variable "repo_staging" {
  type = map(any)
}

variable "repo_dev" {
  type = map(any)
}

resource "github_repository_file" "index" {
  repository = github_repository.intro-repo.name
  content = templatefile("${path.module}/templates/index.tftpl", {
    avatar_url = data.github_user.current.avatar_url
    # date       = formatdate("YYYY", timestamp())
    date         = time_static.build-time.year
    name         = data.github_user.current.name
    username     = data.github_user.current.login
    repo_staging = var.repo_staging
    repo_dev     = var.repo_dev
  })
  file                = "index.md"
  branch              = "main"
  overwrite_on_create = true
}
