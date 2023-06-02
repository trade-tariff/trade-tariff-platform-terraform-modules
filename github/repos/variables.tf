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
  type    = string
  default = "private"
}

variable "archived" {
  type    = bool
  default = false
}

variable "push_teams" {
  type    = list(any)
  default = []
}

variable "read_teams" {
  type    = list(any)
  default = []
}
variable "maintain_teams" {
  type    = list(any)
  default = []
}

variable "admin_teams" {
  type    = list(any)
  default = []
}

variable "allow_push_to_main" {
  type    = string
  default = "true"
}

variable "default_branch_name" {
  type    = string
  default = "main"
}

variable "strict_status_check" {
  type        = bool
  default     = true
  description = "Whether to require branches to be up-to-date before merging."
}

variable "require_signed_commits" {
  type        = bool
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
  default     = []
}

variable "required_approving_review_count" {
  type    = number
  default = 2
}

variable "require_code_owner_reviews" {
  type    = bool
  default = false
}

variable "has_projects" {
  type    = bool
  default = false
}

variable "has_issues" {
  type    = bool
  default = false
}

variable "allow_rebase_merge" {
  type    = bool
  default = false
}

variable "allow_squash_merge" {
  type    = bool
  default = true
}

variable "has_downloads" {
  type    = bool
  default = true
}

variable "delete_branch_on_merge" {
  type    = bool
  default = true
}

variable "has_wiki" {
  type    = bool
  default = false
}

variable "enforce_admins" {
  description = "Whether to enforce branch protection against admins e.g. no push to main, no merge without approvals"
  type        = bool
  default     = false
}

variable "required_status_check_contexts" {
  description = "List of status checks which need to pass before a pull-request can be merged."
  type        = list(any)
  default     = []
}

variable "vulnerability_alerts" {
  description = "GitHub vulnerability alerts"
  type        = bool
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
