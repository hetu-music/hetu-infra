variable "region" {
  description = "The AWS region to deploy the ACM certificate into"
  type        = string
}

variable "name" {
  description = "Short name prefix used to tag this certificate"
  type        = string
  default     = "hetu-infra"
}

variable "domain_name" {
  description = "Primary domain for the cert. Wildcards (e.g. *.hetu-music.com) are fine."
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domains this cert should also cover, if any."
  type        = list(string)
  default     = []
}

variable "zone_id" {
  description = "Cloudflare Zone ID for DNS validation records"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource this module creates"
  type        = map(string)
  default     = {}
}
