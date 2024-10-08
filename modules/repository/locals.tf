locals {
  # New repositories are added to this list
  repositories_list = [
    {
      name        = "go_worker_template"
      description = "A repository template for containerised backend workers written in the Go language. Comes with a containerised MySQL instance and various application layer boilerplates already written."
      topics      = ["golang", "ci", "worker", "docker", "cd"]

      visibility = "public"

      gitignore_template = "Go" # name as found on https://github.com/github/gitignore

      delete_branch_on_merge = true

      is_template = true

      enable_vulnerability_alerts = true
      enable_dependabot_updates   = true

      has_issues      = true
      has_discussions = false
      has_projects    = false
      has_wiki        = false

      allows_force_pushes = false
      force_push_bypassers = [
        "/RazvanBerbece"
      ]

      collaborators = [
        {
          username   = "ant-devbot"
          permission = "admin"
        }
      ]
    },
    {
      name        = "go-htmx-playground"
      description = "Playground for a server-rendered web application built with Go, HTMX and Templ."
      topics      = ["golang", "htmx", "templ"]

      visibility = "public"

      gitignore_template = "Go" # name as found on https://github.com/github/gitignore

      delete_branch_on_merge = true

      is_template = false

      enable_vulnerability_alerts = true
      enable_dependabot_updates   = true

      has_issues      = true
      has_discussions = false
      has_projects    = false
      has_wiki        = false

      allows_force_pushes = false
      force_push_bypassers = [
        "/RazvanBerbece"
      ]

      collaborators = []
    },
    {
      name        = "ant.dev"
      description = "My fun little server-rendered blog written with Go, Templ and a sprinkle of HTMX."
      topics      = ["golang", "htmx", "templ", "blog"]

      visibility = "public"

      gitignore_template = "Go" # name as found on https://github.com/github/gitignore

      delete_branch_on_merge = true

      is_template = false

      enable_vulnerability_alerts = true
      enable_dependabot_updates   = true

      has_issues      = true
      has_discussions = false
      has_projects    = false
      has_wiki        = false

      allows_force_pushes = false
      force_push_bypassers = [
        "/RazvanBerbece"
      ]

      collaborators = [
        {
          username   = "ant-devbot"
          permission = "admin"
        }
      ]
    },
  ]
}


# These shouldn't change, unless extra configuration values are added to the repositories above
locals {
  repositories_map = tomap({
    for repository in local.repositories_list :
    repository.name => {
      description                 = repository.description
      topics                      = repository.topics
      visibility                  = repository.visibility
      gitignore_template          = repository.gitignore_template
      delete_branch_on_merge      = repository.delete_branch_on_merge
      is_template                 = repository.is_template
      has_issues                  = repository.has_issues
      has_discussions             = repository.has_discussions
      has_projects                = repository.has_projects
      has_wiki                    = repository.has_wiki
      allows_force_pushes         = repository.allows_force_pushes
      force_push_bypassers        = repository.force_push_bypassers
      enable_vulnerability_alerts = repository.enable_vulnerability_alerts
      enable_dependabot_updates   = repository.enable_dependabot_updates
    }
  })

  # Flatten the collaborator list so its map can be passed to github_repository_collaborator for each repository
  flattened_collaborators = flatten([
    for repository in local.repositories_list : [
      for collaborator in repository.collaborators : {
        repository_name = repository.name
        username        = collaborator.username
        permission      = collaborator.permission
      }
    ]
  ])

  collaborators_map = {
    for collaborator in local.flattened_collaborators :
    collaborator.repository_name => {
      username   = collaborator.username
      permission = collaborator.permission
    }
  }
}