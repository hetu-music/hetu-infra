include "root" {
  path = find_in_parent_folders("root.hcl")
}

# CloudFront distribution for pre.hetu-music.com.
# ACM certificate is in stacks/aws/acm/pre; app-facing CNAME is in stacks/cloudflare/dns.

dependency "acm_pre" {
  config_path = "../acm/pre"

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
      comment             = "CloudFront for pre.hetu-music.com"
      aliases             = ["pre.hetu-music.com"]
      origin_id           = "hetu-infra-pre"
      origin_domain_name  = get_env("PRE_ORIGIN_DOMAIN_NAME", "")
      acm_certificate_arn = dependency.acm_pre.outputs.certificate_arn
    }
  }
}

