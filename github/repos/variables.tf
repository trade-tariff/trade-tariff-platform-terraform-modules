variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "homepage_url" {
  type    = string
  default = ""
}

variable "visibility" {
  default = "private"
}

variable "archived" {
  default = false
}

variable "push_teams" {
  default = []
}

variable "read_teams" {
  default = []
}
variable "maintain_teams" {
  default = []
}

variable "admin_teams" {
  default = []
}


variable "allow_push_to_main" {
  default = "true"
}

variable "default_branch_name" {
  default = "main"
}

variable "strict_status_check" {
  default     = false
  description = "Whether to require branches to be up-to-date before merging."
}

variable "require_signed_commits" {
  default     = false
  description = "Whether this branch requires all commits to be signed before push or merge."
}

variable "is_template" {
  type        = bool
  default     = null
  description = "Set to true to tell GitHub that this is a template repository."
}

variable "template" {
  description = "Template repository and owner to use"
  type        = list(map(string))

  default = [
  ]
}

variable "required_approving_review_count" {
  default = 2
}

variable "require_code_owner_reviews" {
  default = false
}

variable "has_issues" {
  type    = bool
  default = true
}

variable "allow_rebase_merge" {
  type    = bool
  default = true
}

variable "allow_squash_merge" {
  type    = bool
  default = true
}

variable "has_downloads" {
  type    = bool
  default = false
}

variable "delete_branch_on_merge" {
  type    = bool
  default = true
}

variable "has_wiki" {
  default = false
}

variable "enforce_admins" {
  description = "Whether to enforce branch protection against admins e.g. no push to main, no merge without approvals"
  default     = false
}

variable "required_status_check_contexts" {
  description = "List of status checks which need to pass before a pull-request can be merged."
  default     = []
}

variable "vulnerability_alerts" {
  description = "GitHub vulnerability alerts"
  default     = false
}

variable "pages" {
  description = "(Optional) The repository's GitHub Pages configuration. (Default: {})"
  # type = object({
  # branch = string
  # path   = string
  # cname  = string
  # })
  type    = any
  default = null
}