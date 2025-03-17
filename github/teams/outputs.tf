output "team_id" {
  description = "ID of the parent team."
  value       = github_team.parent_team.id
}

output "team_slug" {
  description = "Slug of the parent team."
  value       = github_team.parent_team.slug
}

output "sub_team_ids" {
  description = "List of IDs of created sub-teams."
  value       = [for i in github_team.this : i.id]
}

output "sub_teams" {
  description = "Map of sub-team slug and ID."
  value       = { for i in github_team.this : i.slug => i.id }
}
