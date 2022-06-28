output "teams" {
  value = var.sub_teams
}

output "id" {
  value = try(github_team.this[0].id, null)
}
