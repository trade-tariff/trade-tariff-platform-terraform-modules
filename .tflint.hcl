config {
  format        = "compact"
  ignore_module = {}
  varfile       = []
  module        = true
}

plugin "terraform" {
  enabled = true
  preset  = "all"
}

plugin "aws" {
  enabled = true
  version = "0.23.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
