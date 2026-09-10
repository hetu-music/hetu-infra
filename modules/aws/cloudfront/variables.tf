variable "region" {
  description = "CloudFront itself is global — this only sets where the AWS provider's other API calls originate from"
  type        = string
  default     = "ap-northeast-1"
}

variable "distributions" {
  description = "Map of CloudFront distributions to manage."
  type = map(object({
    comment             = optional(string, "")
    aliases             = list(string)
    origin_id           = string
    origin_domain_name  = string
    origin_path         = optional(string, "")
    acm_certificate_arn = string
    grpc_enabled        = optional(bool, false)
    tags                = optional(map(string), {})
  }))
  default = {}
}
