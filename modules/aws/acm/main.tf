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
  # Deduplicate domain names statically (e.g. "*.example.com" and "example.com" share the same validation record)
  # so that for_each keys are static and fully known during the plan phase.
  distinct_domains = toset([
    for d in concat([var.domain_name], var.subject_alternative_names) : replace(d, "*.", "")
  ])

  validations = {
    for domain in local.distinct_domains : domain => [
      for dvo in aws_acm_certificate.this.domain_validation_options : {
        name  = trimsuffix(dvo.resource_record_name, ".")
        type  = dvo.resource_record_type
        value = trimsuffix(dvo.resource_record_value, ".")
      }
      if replace(dvo.domain_name, "*.", "") == domain
    ][0]
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
