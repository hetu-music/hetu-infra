resource "cloudflare_dns_record" "dns" {
  for_each = var.records

  zone_id  = var.zone_id
  name     = each.value.name
  type     = each.value.type
  content  = each.value.content
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  comment  = each.value.comment == "" ? null : each.value.comment
  priority = each.value.priority
  tags     = distinct(concat(var.tags, each.value.tags))
}
