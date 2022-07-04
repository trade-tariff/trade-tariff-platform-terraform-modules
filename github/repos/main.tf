resource "github_repository" "repo" {
  name         = var.name
  description  = var.description
  homepage_url = var.homepage_url
  visibility   = var.visibility
  archived     = var.archived
  auto_init    = "true"
  is_template  = var.is_template

  has_wiki               = var.has_wiki
  has_issues             = var.has_issues
  has_downloads          = var.has_downloads
  allow_rebase_merge     = var.allow_rebase_merge
  allow_squash_merge     = var.allow_squash_merge
  delete_branch_on_merge = var.delete_branch_on_merge

  vulnerability_alerts = var.vulnerability_alerts

  dynamic "template" {
    for_each = var.template
    content {
      owner      = lookup(template.value, "owner", "")
      repository = lookup(template.value, "repository", "")
    }
  }

  dynamic "pages" {
    for_each = var.pages != null ? [true] : []

    content {
      source {
        branch = var.pages.branch
        path   = try(var.pages.path, "/")
      }
      cname = try(var.pages.cname, null)
    }
  }

  lifecycle {
    ignore_changes = [topics, auto_init, template, gitignore_template]
  }
}

# TODO:
# We currently have each type of github_team_repository split out into individual resources whereas this could be dyanmically created depending on whether it's push, pull, maintain or admin.
resource "github_team_repository" "repo_team_push" {
  count = length(var.push_teams)

  team_id    = var.push_teams[count.index]
  repository = github_repository.repo.name
  permission = var.archived == "true" ? "pull" : "push"

  lifecycle {
    ignore_changes = [etag]
  }
}

resource "github_team_repository" "repo_team_pull" {
  count = length(var.read_teams)

  team_id    = var.read_teams[count.index]
  repository = github_repository.repo.name
  permission = "pull"

  lifecycle {
    ignore_changes = [etag]
  }

}
resource "github_team_repository" "repo_team_maintain" {
  count = length(var.maintain_teams)

  team_id    = var.maintain_teams[count.index]
  repository = github_repository.repo.name
  permission = "maintain"

  lifecycle {
    ignore_changes = [etag]
  }
}

resource "github_team_repository" "repo_team_admin" {
  count = length(var.admin_teams)

  team_id    = var.admin_teams[count.index]
  repository = github_repository.repo.name
  permission = "admin"

  lifecycle {
    ignore_changes = [etag]
  }
}

resource "github_branch_protection" "repo_protect_main" {
  count = var.allow_push_to_main ? 0 : 1

  repository_id          = github_repository.repo.node_id
  pattern                = var.default_branch_name
  enforce_admins         = var.enforce_admins
  require_signed_commits = var.require_signed_commits

  required_status_checks {
    strict   = var.strict_status_check
    contexts = var.required_status_check_contexts
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = var.required_approving_review_count
    require_code_owner_reviews      = var.require_code_owner_reviews
  }
}
