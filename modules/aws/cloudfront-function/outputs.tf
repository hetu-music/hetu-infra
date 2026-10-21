output "arn" {
  description = "ARN of the provisioned CloudFront Function"
  value       = aws_cloudfront_function.this.arn
}

output "id" {
  description = "ID of the provisioned CloudFront Function"
  value       = aws_cloudfront_function.this.id
}

output "status" {
  description = "Status of the CloudFront Function"
  value       = aws_cloudfront_function.this.status
}
