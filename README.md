# github-iac-manager
Repository that manages my GitHub repositories via IaC with Terraform.

# Features
- Creates and manages GitHub repositories by adding new declarations in the [repositories_list](./modules/repository/locals.tf)
- Manages GitHub collaborators for target repositories
- Creates and manages GitHub secrets for target repositories (TODO)

## Personal repositories on GitHub Free

This configuration targets RazvanBerbece's personal account on GitHub Free.

- Branch protection is managed only for public repositories. GitHub requires a
  paid plan for private repository branch protection. `Tickervolt` and
  `go-htmx-playground` remain private and have no managed branch protection.
- `allows_force_pushes` and `force_push_bypassers` apply only where branch
  protection is supported. On the private repositories, GitHub Free cannot enforce
  an owner-only force-push exception or prevent collaborators from force-pushing.
- Personal repository collaborators receive the standard read/write access
  (`push` in Terraform). Organization roles such as `admin` are not supported
  for personal repository invitations. `ant-devbot` uses `push` on all three
  repositories where it is declared.
- Vulnerability alerts and Dependabot security updates remain enabled for both
  public and private repositories.

See GitHub's documentation on [protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
and [personal repository permissions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/permission-levels-for-a-personal-account-repository).

### Policy checks

CI runs a mocked Terraform plan for the repository module, without GitHub API
calls or HCP Terraform state. To run it locally with the pinned Terraform version:

```sh
cp .terraform.lock.hcl modules/repository/.terraform.lock.hcl
terraform -chdir=modules/repository init -backend=false -input=false -lockfile=readonly
terraform -chdir=modules/repository test -no-color
```
