output "team_id" {
  description = "ID of the parent team."
  value       = github_team.parent_team.id
}

output "sub_team_ids" {
  description = "Map of IDs of created sub-teams."
  value = {
    for i in var.sub_teams :
    i => github_team.this[i].id
  }
}
