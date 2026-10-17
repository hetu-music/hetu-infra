resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Deduplicate by resource_record_name: apex domain and wildcard SAN (e.g. example.com and *.example.com)
  # produce identical CNAME validation records, which would otherwise conflict in Cloudflare.
  validations = {
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.resource_record_name => {
      name  = trimsuffix(dvo.resource_record_name, ".")
      type  = dvo.resource_record_type
      value = trimsuffix(dvo.resource_record_value, ".")
    }
  }
}

# Never proxied — a proxied CNAME resolves to Cloudflare's edge IPs, not the real target,
# which would break ACM's DNS validation lookup.
resource "cloudflare_dns_record" "validation" {
  for_each = local.validations

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = 60
  proxied = false
  comment = "ACM DNS validation for ${var.name} (${each.value.name})"
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in cloudflare_dns_record.validation : r.name]
}
