terraform {
  cloud {
    organization = "antonio-dev-org"

    workspaces {
      name = "gha-iac"
    }
  }
}