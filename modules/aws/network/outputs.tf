output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = [for k, v in local.public_subnets : aws_subnet.this[k].id]
}

output "app_subnet_ids" {
  value = [for k, v in local.app_subnets : aws_subnet.this[k].id]
}

output "data_subnet_ids" {
  value = [for k, v in local.data_subnets : aws_subnet.this[k].id]
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "data_security_group_id" {
  value = aws_security_group.data.id
}
