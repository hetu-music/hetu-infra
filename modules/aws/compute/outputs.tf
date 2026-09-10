output "autoscaling_group_name" {
  description = "Consumed by the aws/alb stack to attach its target group"
  value       = aws_autoscaling_group.this.name
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.this.arn
}

output "launch_template_id" {
  value = aws_launch_template.this.id
}
