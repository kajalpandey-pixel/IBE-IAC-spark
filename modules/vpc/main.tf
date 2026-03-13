resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true  # required for ECS + RDS hostname resolution

  tags = { Name = "${var.project}-vpc" }
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  # ALB requires public subnets to auto-assign public IPs
  map_public_ip_on_launch = true

  tags = { Name = "${var.project}-${var.environment}-public-${var.azs[count.index]}" }
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  # ECS Fargate tasks — no public IPs, outbound via NAT
  map_public_ip_on_launch = false

  tags = { Name = "${var.project}-${var.environment}-private-${var.azs[count.index]}" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project}-${var.environment}-igw" }
}

# This consumes EIP #1 (of your 2 EIP limit)
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "${var.project}-${var.environment}-nat-eip" }

  depends_on = [aws_internet_gateway.main]
}

# ECS tasks use this for outbound: ECR image pulls, SES, SQS calls
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id 

  tags = { Name = "${var.project}-${var.environment}-nat" }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.project}-${var.environment}-rt-public" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private subnets route outbound through NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "${var.project}-${var.environment}-rt-private" }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Required by AWS even for single-AZ free tier RDS
# Spans both private subnets across 2 AZs
resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-${var.environment}-rds-subnet-group"
  description = "RDS subnet group for IBE spans 2 AZs as required by AWS"
  subnet_ids  = aws_subnet.private[*].id

  tags = { Name = "${var.project}-${var.environment}-rds-subnet-group" }
}
