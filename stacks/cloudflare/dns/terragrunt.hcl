include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Cloudflare DNS records for hetu-infra services.

dependency "cloudfront" {
  config_path = "../../aws/cloudfront"

  mock_outputs = {
    distributions = {
      "pre" = { domain_name = "mock123.cloudfront.net" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../modules/cloudflare/dns"
}

inputs = {
  zone_id = get_env("CLOUDFLARE_ZONE_ID", "")

  tags = [
    "project:hetu-infra",
    "environment:production",
    "managed-by:hetu-infra",
  ]

  records = {
    "pre" = {
      name    = "pre.hetu-music.com"
      type    = "CNAME"
      content = dependency.cloudfront.outputs.distributions["pre"].domain_name
      proxied = false
      comment = "hetu-infra: pre.hetu-music.com -> CloudFront"
    }
  }
}
