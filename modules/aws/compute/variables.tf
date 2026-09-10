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

variable "subnet_ids" {
  description = "App-tier subnet IDs (aws/network stack's app_subnet_ids output)"
  type        = list(string)
}

variable "security_group_id" {
  description = "app-sg id (aws/network stack's app_security_group_id output)"
  type        = string
}

variable "instance_profile_name" {
  description = "aws/iam stack's ec2_instance_profile_name output"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (arm64/Graviton)"
  type        = string
  default     = "t4g.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 30
}

variable "min_size" {
  type    = number
  default = 1
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "target_group_arns" {
  description = "Target group ARNs for the ASG to register with"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = {}
}
