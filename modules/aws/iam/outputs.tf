output "github_oidc_provider_arn" {
  value = local.oidc_provider_arn
}

output "hetu_infra_ci_role_arn" {
  description = "For hetu-infra's own GitHub Actions: aws-actions/configure-aws-credentials role-to-assume"
  value       = aws_iam_role.hetu_infra_ci.arn
}

output "hetu_config_ci_role_arn" {
  description = "For kato-config's GitHub Actions: aws-actions/configure-aws-credentials role-to-assume"
  value       = aws_iam_role.hetu_config_ci.arn
}

output "ec2_role_arn" {
  value = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "Attach this to the Launch Template in the aws/compute stack"
  value       = aws_iam_instance_profile.ec2.name
}

output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2.arn
}
