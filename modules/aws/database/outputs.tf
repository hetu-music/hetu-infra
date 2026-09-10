output "endpoint" {
  description = "Hostname only (no port) — matches postgres_host in kato-config's group_vars"
  value       = aws_db_instance.this.address
}

output "port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN of the RDS-managed master password"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "instance_id" {
  value = aws_db_instance.this.id
}
