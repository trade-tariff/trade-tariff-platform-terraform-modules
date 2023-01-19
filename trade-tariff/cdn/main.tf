data "aws_route53_zone" "selected" {
  name         = var.base_domain_name
  private_zone = false
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

module "cdn" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/cloudfront?ref=aws/cloudfront-v1.0.0"

  aliases         = var.cdn_aliases
  route53_zone_id = data.aws_route53_zone.selected.id

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  web_acl_id = var.web_acl_id

  logging_config = {
    bucket = "trade-tariff-logs.s3.amazonaws.com"
    prefix = "cloudfront/${var.environment_key}"
  }

  origin = {
    "frontend-govpaas-${var.environment_name}" = {
      domain_name = var.origin_endpoint
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols = [
          "TLSv1.2",
        ]
      }
    }
  }

  cache_behavior = {
    default = {
      target_origin_id       = "frontend-govpaas-${var.environment_name}"
      viewer_protocol_policy = "redirect-to-https"

      cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.forward_all_qsa.id

      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0

      compress = false

      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS",
        "PUT",
        "POST",
        "PATCH",
        "DELETE"
      ]

      cached_methods = [
        "GET",
        "HEAD"
      ]
    },
  }

  viewer_certificate = {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = module.acm.aws_acm_certificate_arn

    depends_on = [
      module.acm.aws_acm_certificate_arn
    ]
  }
}

module "acm" {
  source = "git@github.com:trade-tariff/trade-tariff-platform-terraform-modules.git//aws/acm?ref=v0.0.2"

  domain_name               = var.cdn_aliases[0]
  subject_alternative_names = slice(var.cdn_aliases, 1, length(var.cdn_aliases))
  route53_zone_id           = data.aws_route53_zone.selected.id
}
