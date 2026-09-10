output "certificate_arn" {
  description = "Validated — safe to reference directly (e.g. aws/alb's certificate_arn, or a CloudFront distribution's viewer_certificate)"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "domain_name" {
  value = var.domain_name
}
