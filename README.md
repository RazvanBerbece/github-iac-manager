# github-iac-manager
Repository that manages my GitHub repositories via IaC with Terraform.

# Features
- Creates and manages GitHub repositories by adding new declarations in the [repositories_list](./modules/repository/locals.tf)
- Manages GitHub collaborators for target repositories
- Creates and manages GitHub secrets for target repositories (TODO)