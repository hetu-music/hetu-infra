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

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  description = "alb-sg id (aws/network stack's alb_security_group_id output)"
  type        = string
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener. If null, only HTTP :80 is configured."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = {}
}
