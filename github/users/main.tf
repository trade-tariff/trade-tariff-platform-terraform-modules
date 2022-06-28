resource "github_team_membership" "this" {
  count = length(var.teams)

  team_id  = var.teams[count.index]
  username = var.username
  role     = var.is_maintainer ? "maintainer" : "member"
}
