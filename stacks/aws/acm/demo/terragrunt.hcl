include "root" {
  path = find_in_parent_folders("root.hcl")
}

# ACM certificate for aws.hetu-music.com in ap-northeast-1 (for ALB).

terraform {
  source = "../../../../modules/aws/acm"
}

inputs = {
  region      = "ap-northeast-1"
  name        = "hetu-infra-demo"
  domain_name = "aws.hetu-music.com"
  zone_id     = get_env("CLOUDFLARE_ZONE_ID", "")

  tags = {
    Project     = "hetu-infra"
    Environment = "demo"
    ManagedBy   = "hetu-infra"
  }
}
