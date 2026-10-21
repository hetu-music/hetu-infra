include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Wildcard ACM certificate for hetu-music.com and *.hetu-music.com in us-east-1 (required for CloudFront).

terraform {
  source = "../../../../modules/aws/acm"
}

inputs = {
  region                    = "us-east-1"
  name                      = "hetu-infra-wildcard"
  domain_name               = "hetu-music.com"
  subject_alternative_names = ["*.hetu-music.com"]
  zone_id                   = get_env("CLOUDFLARE_ZONE_ID", "")

  tags = {
    Project     = "hetu-infra"
    Environment = "production"
    ManagedBy   = "hetu-infra"
  }
}
