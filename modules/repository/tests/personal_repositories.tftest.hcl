mock_provider "github" {}

variables {
  github_token = "mock-token"
}

run "github_free_personal_repositories" {
  command = plan

  assert {
    condition = toset(keys(github_branch_protection.managed_repositories_branch_protections)) == toset([
      "ant.dev", "go_worker_template"
    ])
    error_message = "Protect public repositories only; private branch protection requires a paid plan."
  }

  assert {
    condition = alltrue([
      for protection in github_branch_protection.managed_repositories_branch_protections :
      protection.pattern == "main" && protection.enforce_admins &&
      !protection.allows_force_pushes &&
      toset(protection.force_push_bypassers) == toset(["/RazvanBerbece"])
    ])
    error_message = "Retain main-branch protection and the owner's force-push bypass on public repositories."
  }

  assert {
    condition = alltrue([
      for name in ["Tickervolt", "go-htmx-playground"] :
      github_repository.managed_repositories[name].visibility == "private"
    ])
    error_message = "Keep Tickervolt and go-htmx-playground private."
  }

  assert {
    condition = (
      toset(keys(github_repository_collaborators.managed_repositories_collaborators)) == toset(["Tickervolt", "ant.dev", "go_worker_template"]) &&
      alltrue([
        for collaborators in github_repository_collaborators.managed_repositories_collaborators :
        length(collaborators.user) == 1 &&
        one(collaborators.user).username == "ant-devbot" &&
        one(collaborators.user).permission == "push"
      ])
    )
    error_message = "Grant ant-devbot standard personal-repository write access exactly once on each declared repository."
  }

  assert {
    condition = (
      github_repository.managed_repositories["Tickervolt"].gitignore_template == null &&
      github_repository.managed_repositories["Tickervolt"].license_template == null &&
      !coalesce(github_repository.managed_repositories["Tickervolt"].auto_init, false) &&
      github_repository.managed_repositories["Tickervolt"].has_issues &&
      github_repository.managed_repositories["Tickervolt"].delete_branch_on_merge &&
      !github_repository.managed_repositories["Tickervolt"].is_template
    )
    error_message = "Keep Tickervolt empty, with issues and branch cleanup enabled, and not a template."
  }

  assert {
    condition = alltrue([
      for name in keys(github_repository.managed_repositories) :
      github_repository_vulnerability_alerts.managed_repositories_vulnerability_alerts[name].enabled &&
      github_repository_dependabot_security_updates.managed_repositories_dependabot_updates[name].enabled
    ])
    error_message = "Retain vulnerability alerts and Dependabot security updates for every repository."
  }
}
