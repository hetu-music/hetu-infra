variable "region" {
  description = "CloudFront itself is global — this only sets where the AWS provider's other API calls originate from"
  type        = string
  default     = "ap-northeast-1"
}
variable "name" {
  description = "Name prefix for CloudFront resources"
  type        = string
  default     = "hetu-infra"
}

variable "tags" {
  description = "Tags applied to all CloudFront distributions"
  type        = map(string)
  default     = {}
}

variable "distributions" {
  description = "Map of CloudFront distributions to manage."
  type = map(object({
    comment                  = optional(string, "")
    aliases                  = list(string)
    origin_id                = string
    origin_domain_name       = string
    origin_path              = optional(string, "")
    acm_certificate_arn      = string
    grpc_enabled             = optional(bool, false)
    cache_policy_id          = optional(string, null)
    origin_request_policy_id = optional(string, null)
    geo_restriction = optional(object({
      restriction_type = optional(string, "none")
      locations        = optional(list(string), [])
    }), {})
    enable_security_guard = optional(bool, false)
    function_associations = optional(list(object({
      event_type   = string
      function_arn = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
