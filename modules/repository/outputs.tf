output "github_repositories_full_names" {
  value       = zipmap(values(github_repository.managed_repositories)[*].name, values(github_repository.managed_repositories)[*].full_name)
  description = "List of full names (\"orgname/reponame\") for GitHub repositories managed by this resource"
}

output "github_repositories_html_urls" {
  value       = zipmap(values(github_repository.managed_repositories)[*].name, values(github_repository.managed_repositories)[*].html_url)
  description = "List of URLs for the GitHub repositories managed by this resource"
}

output "collaborator_invitation_ids" {
  value       = zipmap(values(github_repository.managed_repositories)[*].name, values(github_repository_collaborator.managed_repositories_collaborators)[*].invitation_id)
  description = "List of invitation IDs for the collaborators added to the GitHub repositories managed by this resource"
}
