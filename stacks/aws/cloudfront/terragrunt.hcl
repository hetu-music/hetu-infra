include "root" {
  path = find_in_parent_folders("root.hcl")
}

# CloudFront distributions for pre.hetu-music.com and www.hetu-music.com.
# ACM certificate is in stacks/aws/acm/wildcard; app-facing CNAME is in stacks/cloudflare/dns.

dependency "acm_wildcard" {
  config_path = "../acm/wildcard"

  mock_outputs = {
    certificate_arn = "arn:aws:acm:us-east-1:000000000000:certificate/00000000-0000-0000-0000-000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../modules/aws/cloudfront"
}

inputs = {
  region = "ap-northeast-1"
  name   = "hetu-infra"

  tags = {
    Project     = "hetu-infra"
    Environment = "production"
    ManagedBy   = "hetu-infra"
  }

  distributions = {
    "pre" = {
      comment                  = "CloudFront for pre.hetu-music.com"
      aliases                  = ["pre.hetu-music.com"]
      origin_id                = "hetu-infra-pre"
      origin_domain_name       = get_env("PRE_ORIGIN_DOMAIN_NAME", "")
      acm_certificate_arn      = dependency.acm_wildcard.outputs.certificate_arn
      cache_policy_id          = "CachingDisabled"
      origin_request_policy_id = "AllViewerExceptHostHeader"
    }
    "www" = {
      comment                  = "CloudFront for www.hetu-music.com"
      aliases                  = ["www.hetu-music.com"]
      origin_id                = "hetu-infra-www"
      origin_domain_name       = get_env("WWW_ORIGIN_DOMAIN_NAME", "")
      acm_certificate_arn      = dependency.acm_wildcard.outputs.certificate_arn
      cache_policy_id          = "UseOriginCacheControlHeaders-QueryStrings" # Only caches when origin sends Cache-Control; includes query strings in cache key
      origin_request_policy_id = "AllViewer"
    }
  }
}

