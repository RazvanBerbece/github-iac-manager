resource "github_repository" "managed_repositories" {
  for_each = local.repositories_map

  name        = each.key
  description = each.value.description
  topics      = each.value.topics

  gitignore_template = each.value.gitignore_template

  delete_branch_on_merge = each.value.delete_branch_on_merge

  visibility = each.value.visibility

  is_template = each.value.is_template

  has_issues      = each.value.has_issues
  has_discussions = each.value.has_discussions
  has_projects    = each.value.has_projects
  has_wiki        = each.value.has_wiki
}