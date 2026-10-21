variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "ap-northeast-1"
}

variable "name" {
  description = "Short name prefix used to tag/name every resource this module creates"
  type        = string
  default     = "hetu-infra"
}

variable "state_bucket" {
  description = "S3 bucket the hetu-infra-ci role needs read/write on (this repo's own remote state)"
  type        = string
  default     = "hetu-infra"
}

variable "create_github_oidc_provider" {
  description = "Whether to create the GitHub OIDC provider. Set to false if already exists in account."
  type        = bool
  default     = true
}

variable "existing_github_oidc_provider_arn" {
  description = "Optional ARN when create_github_oidc_provider = false; defaults to current account's OIDC provider if left empty"
  type        = string
  default     = ""
}

variable "ssm_parameter_prefix" {
  description = "SSM Parameter Store path prefix the EC2 role may read (SecureString app config)"
  type        = string
  default     = "/hetu-web"
}

variable "cloudfront_purge_distribution_ids" {
  description = "List of CloudFront distribution IDs (or ARNs) that the purge user is permitted to invalidate"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = {}
}
