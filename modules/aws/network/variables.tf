variable "name" {
  description = "Short name prefix used to tag/name every resource this module creates"
  type        = string
  default     = "hetu-infra"
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "app_port" {
  description = "Port the application listens on (allowed from alb-sg into app-sg)"
  type        = number
  default     = 3000
}

variable "subnets" {
  description = "3-tier subnet layout across availability zones (public, app, data)"
  type = map(object({
    cidr_block = string
    az         = string
    tier       = string
  }))
  default = {
    "public-a" = { cidr_block = "10.20.0.0/24",  az = "ap-northeast-1a", tier = "public" }
    "public-c" = { cidr_block = "10.20.1.0/24",  az = "ap-northeast-1c", tier = "public" }
    "app-a"    = { cidr_block = "10.20.16.0/24", az = "ap-northeast-1a", tier = "app" }
    "app-c"    = { cidr_block = "10.20.17.0/24", az = "ap-northeast-1c", tier = "app" }
    "data-a"   = { cidr_block = "10.20.32.0/24", az = "ap-northeast-1a", tier = "data" }
    "data-c"   = { cidr_block = "10.20.33.0/24", az = "ap-northeast-1c", tier = "data" }
  }
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = {}
}
