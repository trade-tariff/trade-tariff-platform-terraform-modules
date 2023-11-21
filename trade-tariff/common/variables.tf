variable "project-key" {
  type        = string
  description = "The project key to use in prefixing resources"
  default     = "trade-tariff"
}


variable "environments" {
  type        = list(any)
  description = "list of environment name keys to use in environment interpolations"
  default     = ["development", "staging", "production"]
}



variable "docker_repositories" {
  type        = list(string)
  description = "List of repositories to create"
  default = [
    "tariff-backend",
    "tariff-frontend",
    "tariff-dutycalculator",
    "tariff-admin",
    "tariff-search-query-parser",
    "signon",
  ]
}
