output "github_repositories_full_names" {
  value       = module.repositories.github_repositories_full_names
  description = "Full names (\"orgname/reponame\") of the GitHub repositories managed by this resource"
}

output "github_repositories_html_urls" {
  value       = module.repositories.github_repositories_html_urls
  description = "URLs of the GitHub repositories managed by this resource"
}

output "collaborator_invitation_ids" {
  value = module.repositories.collaborator_invitation_ids
  description = "Invitation IDs of the collaborators added to the GitHub repositories managed by this resource"
}