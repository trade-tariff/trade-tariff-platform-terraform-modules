variable "description" {
  description = "A description of the team."
  type        = string
  default     = ""
}

variable "privacy" {
  description = "The level of privacy for the team. Must be one of `secret` or `closed`."
  type        = string
  default     = "secret"
}

variable "sub_teams" {
  description = "A list of sub teams to add to the parent team."
  type        = set(any)
  default     = null
}

variable "create_default_maintainer" {
  type        = string
  description = "Adds the creating user to the team when set to `true`."
  default     = false
}

variable "parent_team_name" {
  description = "The name of the parent team."
  type        = string
}

variable "parent_team_description" {
  description = "The description of the parent team."
  type        = string
  default     = ""
}
