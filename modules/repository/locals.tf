locals {
  # New repositories are added to this list
  repositories_list = [
    {
      name        = "go_worker_template"
      description = "A repository template for backend workers written in the Go language."
      topics      = ["golang", "ci", "worker", "docker", "cd"]

      visibility = "public"

      gitignore_template = "Go" # name as found on https://github.com/github/gitignore

      delete_branch_on_merge = true

      is_template = true

      has_issues      = true
      has_discussions = false
      has_projects    = false
      has_wiki        = false
    },
  ]
}


# This shouldn't change, unless extra configuration values are added to the repositories above
locals {
  repositories_map = tomap({
    for repository in local.repositories_list :
    repository.name => {
      description            = repository.description
      topics                 = repository.topics
      visibility             = repository.visibility
      gitignore_template     = repository.gitignore_template
      delete_branch_on_merge = repository.delete_branch_on_merge
      is_template            = repository.is_template
      has_issues             = repository.has_issues
      has_discussions        = repository.has_discussions
      has_projects           = repository.has_projects
      has_wiki               = repository.has_wiki
    }
  })
}