include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/aws/cloudfront-function"
}

inputs = {
  region        = "us-east-1"
  name          = "hetu-infra"
  function_name = "security-guard"
  comment       = "Edge security inspection (blocked paths, scanners, bad methods)"
  runtime       = "cloudfront-js-2.0"
  publish       = true
  code          = file("${get_terragrunt_dir()}/security_guard.js")

  tags = {
    Project     = "hetu-infra"
    Environment = "production"
    ManagedBy   = "hetu-infra"
  }
}
