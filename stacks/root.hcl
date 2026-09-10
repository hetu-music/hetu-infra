# Automatically configure remote state for all child stacks.
#
# Uses dedicated state bucket: hetu-infra
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket       = "hetu-infra"
    key          = "${path_relative_to_include()}.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
