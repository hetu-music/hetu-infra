include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/aws/iam"
}

inputs = {
  region                      = "ap-northeast-1"
  name                        = "hetu-infra"
  create_github_oidc_provider = false

  cloudfront_purge_distribution_ids = [
    get_env("CLOUDFRONT_WWW_DISTRIBUTION_ID", "*")
  ]

  tags = {
    Project     = "hetu-infra"
    Environment = "demo"
    ManagedBy   = "hetu-infra"
  }
}
