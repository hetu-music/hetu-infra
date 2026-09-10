variable "zone_id" {
  description = "The target Cloudflare Zone ID"
  type        = string
}

variable "tags" {
  description = "Default tags applied to all DNS records in this module"
  type        = list(string)
  default     = []
}

variable "records" {
  description = "A map of DNS records for this specific zone"
  type = map(object({
    name     = string                     # e.g., "www", "@", etc.
    type     = string                     # A, AAAA, CNAME, TXT, MX, NS, etc.
    content  = string                     # Target value (IP, alias, text, etc.)
    ttl      = optional(number, 1)        # TTL (1 = automatic/auto in Cloudflare)
    proxied  = optional(bool, true)       # Whether to proxy traffic through Cloudflare
    comment  = optional(string)           # Optional description for metadata
    priority = optional(number)           # Optional priority for MX records
    tags     = optional(list(string), []) # Tags for this specific DNS record
  }))
  default = {}
}
