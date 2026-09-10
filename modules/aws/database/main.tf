resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-db" })
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-postgres${var.engine_version}"
  family = "postgres${var.engine_version}"

  tags = merge(var.tags, { Name = "${var.name}-postgres${var.engine_version}" })
}

resource "aws_db_instance" "this" {
  identifier     = var.name
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true

  db_name                     = var.database_name
  username                    = var.master_username
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  parameter_group_name   = aws_db_parameter_group.this.name

  multi_az = var.multi_az

  backup_retention_period = var.backup_retention_days
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection = false
  skip_final_snapshot = true

  copy_tags_to_snapshot         = true
  auto_minor_version_upgrade    = true
  performance_insights_enabled  = true

  tags = merge(var.tags, { Name = var.name })
}

# Automatic password rotation for RDS master user secret
resource "aws_secretsmanager_secret_rotation" "master_password" {
  secret_id = aws_db_instance.this.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = var.password_rotation_days
  }
}
