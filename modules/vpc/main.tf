# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "vpc-${var.vers}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igt-${var.vers}"
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
    Name = "subnet-${var.vers}"
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
    Name = "rt-${var.vers}"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnet_cidr_block)
  subnet_id      = element(aws_subnet.subnet123.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}
