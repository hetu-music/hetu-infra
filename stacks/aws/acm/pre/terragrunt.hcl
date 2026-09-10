include "root" {
  path = find_in_parent_folders("root.hcl")
}

# ACM certificate for pre.hetu-music.com in us-east-1 (required for CloudFront).

terraform {
  source = "../../../../modules/aws/acm"
}

inputs = {
  region      = "us-east-1"
  name        = "hetu-infra-pre"
  domain_name = "pre.hetu-music.com"
  zone_id     = get_env("CLOUDFLARE_ZONE_ID", "")

  tags = {
    Project     = "hetu-infra"
    Environment = "production"
    ManagedBy   = "hetu-infra"
  }
}
