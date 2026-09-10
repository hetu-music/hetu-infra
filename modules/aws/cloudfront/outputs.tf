output "distributions" {
  description = "Detailed configuration of provisioned CloudFront distributions — a cloudflare/dns stack reads domain_name from here for the app-facing CNAME"
  value = {
    for k, v in aws_cloudfront_distribution.this : k => {
      id             = v.id
      arn            = v.arn
      domain_name    = v.domain_name
      hosted_zone_id = v.hosted_zone_id
      status         = v.status
    }
  }
}
