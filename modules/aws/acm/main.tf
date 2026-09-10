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
  # One entry per distinct domain being validated (domain_name + each SAN, deduped by AWS).
  # AWS's resource_record_name/_value come back with a trailing dot; Cloudflare doesn't want it.
  validations = {
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.domain_name => {
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
  comment = "ACM DNS validation for ${var.name} (${each.key})"
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for r in cloudflare_dns_record.validation : r.name]
}
