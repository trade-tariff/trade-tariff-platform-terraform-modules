variable "environment_name" {
}

variable "environment_key" {
}

variable "cdn_aliases" {
  type = list(string)
}

variable "origin_endpoint" {
}

variable "base_domain_name" {
  type    = string
  default = "trade-tariff.service.gov.uk."
}

variable "web_acl_id" {
  description = "If you're using AWS WAF to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the WAF Global (CloudFront) region and the credentials configuring this argument must have waf:GetWebACL permissions assigned. If using WAFv2, provide the ARN of the web ACL."
  type        = string
  default     = null
}
