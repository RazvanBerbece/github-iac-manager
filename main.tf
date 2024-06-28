module "repositories" {
  source = "./modules/repository"

  github_token = var.github_token
}