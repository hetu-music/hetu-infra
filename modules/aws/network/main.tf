locals {
  public_subnets = { for k, v in var.subnets : k => v if v.tier == "public" }
  app_subnets    = { for k, v in var.subnets : k => v if v.tier == "app" }
  data_subnets   = { for k, v in var.subnets : k => v if v.tier == "data" }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-igw" })
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.tier == "public"

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
    Tier = each.value.tier
  })
}

# NAT Gateways: one per public subnet/AZ
resource "aws_eip" "nat" {
  for_each = local.public_subnets
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.name}-nat-${each.key}" })
}

resource "aws_nat_gateway" "this" {
  for_each      = local.public_subnets
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this[each.key].id
  tags          = merge(var.tags, { Name = "${var.name}-nat-${each.key}" })
  depends_on    = [aws_internet_gateway.this]
}

locals {
  # Map AZ to its NAT Gateway ID
  nat_by_az = { for k, sn in local.public_subnets : sn.az => aws_nat_gateway.this[k].id }
}

# Route tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-public-rt" })
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}

# App tier: route 0.0.0.0/0 through the NAT Gateway in the same AZ
resource "aws_route_table" "app" {
  for_each = local.app_subnets
  vpc_id   = aws_vpc.this.id
  tags     = merge(var.tags, { Name = "${var.name}-app-rt-${each.key}" })
}

resource "aws_route" "app_nat" {
  for_each               = local.app_subnets
  route_table_id         = aws_route_table.app[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = local.nat_by_az[each.value.az]
}

resource "aws_route_table_association" "app" {
  for_each       = local.app_subnets
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.app[each.key].id
}

# Data tier: isolated route table without internet access
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "${var.name}-data-rt" })
}

resource "aws_route_table_association" "data" {
  for_each       = local.data_subnets
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.data.id
}

# Security groups: alb -> app -> data
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB: public HTTPS/HTTP ingress"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from the internet (listener redirects to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "EC2 app tier: only reachable from the ALB, on the app port"
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "App traffic from the ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-app-sg" })
}

resource "aws_security_group" "data" {
  name        = "${var.name}-data-sg"
  description = "RDS: only reachable from the app tier on 5432. No egress - RDS never needs it."
  vpc_id      = aws_vpc.this.id

  ingress {
    description     = "Postgres from the app tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = merge(var.tags, { Name = "${var.name}-data-sg" })
}
