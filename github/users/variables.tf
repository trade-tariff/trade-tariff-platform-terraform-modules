variable "username" {
  type = string
}

variable "is_maintainer" {
  type    = string
  default = "false"
}

variable "teams" {
  type    = list(string)
  default = []
}
