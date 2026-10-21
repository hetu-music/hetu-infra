variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name of the CloudFront Function"
  type        = string
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
