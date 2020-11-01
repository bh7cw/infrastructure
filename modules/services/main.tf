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

resource "aws_security_group_rule" "applicationsgr2" {
  type              = var.security_group_rule_in
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = var.security_group_protocl_in
  cidr_blocks       = [var.db_cidr_block]
  security_group_id = aws_security_group.application.id
}

# -------------------------------------------------------------------
# rds aws_security_group
resource "aws_security_group" "database" {
  name        = var.aws_security_group_db
  description = var.aws_security_group_db_desc
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = var.security_group_protocl_in
    security_groups = [aws_security_group.application.id]
    cidr_blocks     = [var.db_cidr_block]
  }

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
# codedeploy plocies
//CodeDeploy-EC2-S3 policy
resource "aws_iam_policy" "codedeploy-ec2-s3-policy" {
  name        = var.aws_iam_codedeploy_ec2_s3_policy_name
  description = var.aws_iam_codedeploy_ec2_s3_policy_description
  policy      = var.aws_iam_codedeploy_ec2_s3_policy_content
}

//GH-Upload-To-S3 policy
resource "aws_iam_policy" "gh-upload-to-s3-policy" {
  name        = var.aws_iam_gh_upload_to_s3_policy_name
  description = var.aws_iam_gh_upload_to_s3_policy_description
  policy      = var.aws_iam_gh_upload_to_s3_policy_content
}

//GH-Code-Deploy policy
resource "aws_iam_policy" "gh-code-deploy-policy" {
  name        = var.aws_iam_gh-code-deploy-policy_name
  description = var.aws_iam_gh-code-deploy-policy_description
  policy      = var.aws_iam_gh-code-deploy-policy_content
}

//gh-ec2-ami policy
resource "aws_iam_policy" "gh-ec2-ami-policy" {
  name        = var.aws_iam_gh_ec2_ami_policy_name
  description = var.aws_iam_gh_ec2_ami_policy_description
  policy      = var.aws_iam_gh_ec2_ami_policy_content
}

//attach GH-Upload-To-S3 policy to `ghaction` user
resource "aws_iam_policy_attachment" "attach1" {
  name       = var.aws_iam_policy_attachment_gh_upload_to_s3_name
  users      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-upload-to-s3-policy.arn
}

//attach GH-Code-Deploy policy to `ghaction` user
resource "aws_iam_policy_attachment" "attach2" {
  name       = var.aws_iam_policy_attachment_gh_code_deploy_name
  users      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-code-deploy-policy.arn
}

//attach gh-ec2-ami policy to `ghaction` user
resource "aws_iam_policy_attachment" "attach3" {
  name       = var.aws_iam_policy_attachment_gh_ec2_ami_name
  users      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-ec2-ami-policy.arn
}

//CodeDeployEC2ServiceRole
resource "aws_iam_role" "code_deploy_ec2_role" {
  name = var.aws_code_deploy_iam_role_name
  assume_role_policy = var.aws_code_deploy_iam_role_assume_role_policy
}

//attach aws_iam_role policy to `CodeDeployEC2ServiceRole` role
resource "aws_iam_policy_attachment" "attach_code_deploy_ec2_role" {
  name       = var.aws_iam_policy_attachment_code_deploy_ec2_name
  roles      = [aws_iam_role.code_deploy_ec2_role.name]
  policy_arn = aws_iam_policy.codedeploy-ec2-s3-policy.arn
}

//CodeDeployServiceRole
resource "aws_iam_role" "code_deploy_service_role" {
  name = var.aws_code_deploy_service_role_name
  assume_role_policy = var.aws_code_deploy_iam_role_assume_role_policy
}

resource "aws_iam_policy_attachment" "attach_code_deploy_service_role" {
    name       = var.aws_iam_policy_attachment_code_deploy_service_name
  roles      = [aws_iam_role.code_deploy_service_role.name]
  policy_arn = var.aws_code_deploy_role
}

# -------------------------------------------------------------------
# aws_iam_instance_profile

resource "aws_iam_instance_profile" "profile" {
  name = var.aws_iam_instance_profile_name
  role = aws_iam_role.role.name
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
# ssh key pair
resource "aws_key_pair" "ssh" {
  key_name   = var.aws_key_pair_name
  public_key = var.aws_key_pair_key
}

# -------------------------------------------------------------------
# ec2 instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = var.aws_iam_ec2_instance_profile_name
  role = aws_iam_role.code_deploy_ec2_role.name
}

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
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  key_name                    = aws_key_pair.ssh.id
  #iam_instance_profile       = "${aws_iam_instance_profile.instance_profile.name}"

  user_data                   = <<EOF
#!/bin/bash
echo export DB_USERNAME="${var.rds_username}" >> /etc/profile
echo export DB_PASSWORD="${var.password}" >> /etc/profile
echo export DB_NAME="${var.aws_dynamodb_table_name}" >> /etc/profile
echo export HOSTNAME="${aws_db_instance.db.endpoint}" >> /etc/profile
echo export BUCKET_NAME="${var.aws_s3_bucket_name}" >> /etc/profile
  EOF

  connection {
    user = var.aws_instance_name
    host = aws_instance.ubuntu.public_ip
  }
  
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
# DNS record of ec2 public ip
/*provider "dns" {
  update {
    server =      "192.168.8.184"
    key_name      = "terraform"
    key_algorithm = "hmac-sha256"
  }
}

resource "dns_a_record_set" "dns_a_record" {
  zone = var.dns_a_record_zone
  name = var.dns_a_record_name
  type    = "A"
  addresses = [aws_instance.ubuntu.public_ip]
  ttl = "60"
}*/

resource "aws_route53_record" "dns_a_record" {
  zone_id = "dev.bh7cw.me"
  name    = var.dns_a_record_name
  type    = var.dns_a_record_type
  ttl     = var.dns_a_record_ttl
  records = [aws_instance.ubuntu.public_ip]
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