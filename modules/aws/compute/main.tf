# Latest AL2023 arm64 AMI from SSM Parameter Store
data "aws_ssm_parameter" "al2023_arm64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-"
  image_id      = data.aws_ssm_parameter.al2023_arm64.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [var.security_group_id]

  metadata_options {
    http_tokens   = "required" # IMDSv2 only
    http_endpoint = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(file("${path.module}/templates/user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = var.name, Role = "app" })
  }

  tags = merge(var.tags, { Name = "${var.name}-lt" })
}

locals {
  health_check_type = length(var.target_group_arns) > 0 ? "ELB" : "EC2"
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name}-asg"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  target_group_arns   = var.target_group_arns

  health_check_type         = EC2
  health_check_grace_period = 300 # katoweb + kong + gotrue + postgrest all cold-starting

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  # Roll instances one at a time whenever the launch template changes (new AMI, user_data edit).
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 300
    }
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Name = var.name, Role = "app" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
