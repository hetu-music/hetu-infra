variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Short name prefix used to tag/name every resource this module creates"
  type        = string
  default     = "hetu-infra"
}

variable "function_name" {
  description = "Name suffix for the CloudFront Function"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = {}
}

variable "runtime" {
  description = "Runtime environment for the function"
  type        = string
  default     = "cloudfront-js-2.0"
}

variable "comment" {
  description = "Comment / description for the function"
  type        = string
  default     = ""
}

variable "publish" {
  description = "Whether to publish creation/change as LIVE"
  type        = bool
  default     = true
}

variable "code" {
  description = "Source code of the function"
  type        = string
}
