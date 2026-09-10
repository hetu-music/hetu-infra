output "records" {
  description = "Summary of DNS records created in this zone"
  value = {
    for k, v in cloudflare_dns_record.dns : k => {
      name    = v.name
      type    = v.type
      proxied = v.proxied
    }
  }
}
