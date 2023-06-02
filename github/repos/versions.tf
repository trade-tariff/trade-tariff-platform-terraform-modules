terraform {
  required_version = ">= 1.1.7"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.23.0"
    }
  }
}
