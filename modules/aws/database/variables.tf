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
  description = "Data-tier subnet IDs (aws/network stack's data_subnet_ids output) — must span 2+ AZs for Multi-AZ"
  type        = list(string)
}

variable "security_group_id" {
  description = "data-sg id (aws/network stack's data_security_group_id output) — only app-sg can reach 5432"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL major engine version"
  type        = string
  default     = "17"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage, GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling, GiB"
  type        = number
  default     = 100
}

variable "database_name" {
  type    = string
  default = "postgres"
}

variable "master_username" {
  type    = string
  default = "postgres"
}

variable "multi_az" {
  type    = bool
  default = true
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "backup_window" {
  description = "UTC — 16:00-17:00 UTC = 01:00-02:00 JST"
  type        = string
  default     = "16:00-17:00"
}

variable "maintenance_window" {
  description = "UTC — sun 17:00-18:00 UTC = Monday 02:00-03:00 JST, outside the backup window"
  type        = string
  default     = "sun:17:00-sun:18:00"
}

variable "password_rotation_days" {
  type    = number
  default = 30
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = {}
}
