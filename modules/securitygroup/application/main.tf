# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "${var.aws_security_group_name}-vpc-${var.vers}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.aws_security_group_name}-igt-${var.vers}"
  }
}

# subnet
resource "aws_subnet" "subnet123" {
  count = length(var.subnet_cidr_block)
  cidr_block           = element(var.subnet_cidr_block,count.index)
  vpc_id = aws_vpc.vpc.id
  availability_zone    = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.aws_security_group_name}-subnet-${var.vers}"
  }
}


# Route table: attach Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.destination
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "${var.aws_security_group_name}-rt-${var.vers}"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnet_cidr_block)
  subnet_id      = element(aws_subnet.subnet123.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}

# aws_security_group
resource "aws_security_group" "sg" {
  name        = var.aws_security_group_name
  description = var.aws_security_group_description
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    description = "mysql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.db_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.security_group_cidr_block]
  }

  tags = {
    Name = var.aws_security_group_name
  }
}

resource "aws_security_group_rule" "sgr" {
  count             = length(var.aws_security_group_ingress_port)
  type              = "ingress"
  from_port         = element(var.aws_security_group_ingress_port,count.index)
  to_port           = element(var.aws_security_group_ingress_port,count.index)
  protocol          = "tcp"
  cidr_blocks       = [var.security_group_cidr_block]
  security_group_id = aws_security_group.sg.id
}
