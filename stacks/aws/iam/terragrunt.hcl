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
  tags = {
    Project     = "hetu-infra"
    Environment = "demo"
    ManagedBy   = "hetu-infra"
  }
}
