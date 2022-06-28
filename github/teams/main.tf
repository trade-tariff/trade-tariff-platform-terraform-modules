resource "github_team" "parent_team" {
  name        = var.parent_team_name
  description = var.parent_team_description
  privacy     = "closed"
}

resource "github_team" "this" {
  for_each = var.sub_teams

  name           = each.value
  description    = var.description
  privacy        = var.privacy
  parent_team_id = github_team.parent_team.id

  create_default_maintainer = var.create_default_maintainer
}
