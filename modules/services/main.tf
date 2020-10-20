provider "aws" {
  region = var.region
}

# -------------------------------------------------------------------
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.tbool
  enable_dns_support   = var.tbool
  enable_classiclink_dns_support = var.tbool
  assign_generated_ipv6_cidr_block = var.fbool
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
    Name = "subnet-${var.vers}-${count.index}"
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

# -------------------------------------------------------------------
# ec2 aws_security_group
resource "aws_security_group" "application" {
  name        = var.aws_security_group_app
  description = var.aws_security_group_app_desc
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = var.security_group_protocl_in
    cidr_blocks = [var.db_cidr_block]
  }

  egress {
    from_port   = var.all_port
    to_port     = var.all_port
    protocol    = var.security_group_protocl_e
    cidr_blocks = [var.security_group_cidr_block]
  }

  tags = {
    Name = var.aws_security_group_app
  }
}

resource "aws_security_group_rule" "applicationsgr" {
  count             = length(var.aws_security_group_ingress_port)
  type              = var.security_group_rule_in
  from_port         = element(var.aws_security_group_ingress_port,count.index)
  to_port           = element(var.aws_security_group_ingress_port,count.index)
  protocol          = var.security_group_protocl_in
  cidr_blocks       = [var.security_group_cidr_block]
  security_group_id = aws_security_group.application.id
}

# -------------------------------------------------------------------
# rds aws_security_group
resource "aws_security_group" "database" {
  name        = var.aws_security_group_db
  description = var.aws_security_group_db_desc
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = var.all_port
    to_port     = var.all_port
    protocol    = var.security_group_protocl_e
    cidr_blocks = [var.security_group_cidr_block]
  }

  tags = {
    Name = var.aws_security_group_db
  }
}

resource "aws_security_group_rule" "databsesgr" {
  count             = length(var.aws_security_group_ingress_port)
  type              = var.security_group_rule_in
  from_port         = element(var.aws_security_group_ingress_port,count.index)
  to_port           = element(var.aws_security_group_ingress_port,count.index)
  protocol          = var.security_group_protocl_in
  cidr_blocks       = [var.security_group_cidr_block]
  security_group_id = aws_security_group.database.id
}

# -------------------------------------------------------------------
# s3
resource "aws_s3_bucket" "b" {
  bucket = var.aws_s3_bucket_name
  force_destroy = var.tbool
  acl    = var.aws_s3_bucket_acl
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.aws_s3_bucket_algorithm
      }
    }
  }

  lifecycle_rule {
    enabled = var.tbool

    noncurrent_version_transition {
      days          = var.aws_s3_bucket_days
      storage_class = var.aws_s3_bucket_storage_class
    }
  }

  tags = {
    Name        = var.aws_s3_bucket_name
  }
}

# -------------------------------------------------------------------
# iam
resource "aws_iam_policy" "policy" {
  name        = var.aws_iam_policy_name
  path        = var.aws_iam_policy_path
  description = var.aws_iam_policy_description

  policy = var.aws_iam_policy_policy
}

resource "aws_iam_role" "role" {
  name = var.aws_iam_role_name
  assume_role_policy = var.aws_iam_role_assume_role_policy
}

resource "aws_iam_policy_attachment" "attach" {
  name       = var.aws_iam_policy_attachment_name
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

# -------------------------------------------------------------------
# ssh key pair
resource "aws_key_pair" "ssh" {
  key_name   = var.aws_key_pair_name
  public_key = var.aws_key_pair_key
}

# -------------------------------------------------------------------
# ec2 instance
data "aws_ami" "ami" {
  most_recent = var.tbool
  owners = [var.ami_owner]
}

resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ami.id
  instance_type               = var.aws_instance_instance_type
  vpc_security_group_ids      = [aws_security_group.application.id]
  subnet_id                   = element(aws_subnet.subnet123.*.id,0)
  disable_api_termination     = var.fbool
  key_name                    = "${aws_key_pair.ssh.id}"
  user_data                   = var.user_data
  
  root_block_device {
    delete_on_termination     = var.tbool
    volume_size               = var.aws_instance_volume_size
    volume_type               = var.aws_instance_volume_type
  } 

  tags = {
    Name = var.aws_instance_name
  }
}

# -------------------------------------------------------------------
# rds instance
resource "aws_db_subnet_group" "_" {
  #name       = "aws-subnet-group"
  subnet_ids = [element(aws_subnet.subnet123.*.id, 1), element(aws_subnet.subnet123.*.id, 2)]
}

resource "aws_db_instance" "db" {
  engine                  = var.rds_engine
  instance_class          = var.rds_instance_class
  multi_az                = var.multi_az
  identifier              = var.rds_identifier
  username                = var.rds_username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group._.id
  vpc_security_group_ids  = [aws_security_group.database.id]
  publicly_accessible     = var.rds_publicly_accessible
  name                    = var.rds_name
  engine_version          = var.rds_engine_version
  allocated_storage       = var.rds_allocated_storage
  final_snapshot_identifier = var.aws_db_instance_final

  #backup_retention_period = var.rds_backup_retention_period
  #backup_window           = var.rds_backup_window
  #maintenance_window      = var.rds_maintenance_window
  #port                    = var.rds_port
  #storage_encrypted       = var.rds_storage_encrypted
  #storage_type            = var.storage_type
  #allow_major_version_upgrade = false
  #auto_minor_version_upgrade  = true
  #final_snapshot_identifier = null
  #snapshot_identifier       = ""
  #skip_final_snapshot       = true
  #performance_insights_enabled = false
}

# -------------------------------------------------------------------
# dynamodb
resource "aws_dynamodb_table" "table" {
  name = var.aws_dynamodb_table_name
  hash_key = var.aws_dynamodb_table_key
  read_capacity  = var.aws_dynamodb_table_capacity
  write_capacity = var.aws_dynamodb_table_capacity

  attribute {
    name = var.aws_dynamodb_table_key
    type = var.aws_dynamodb_table_type
  }
}