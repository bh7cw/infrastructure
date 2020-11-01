variable "region" {
  type = string
  default = "us-east-1"
}

# -------------------------------------------------------------------
# shared
variable "tbool" {
  type = bool
  default = true
}

variable "fbool" {
  type = bool
  default = false
}

# -------------------------------------------------------------------
# VPC
variable "vers" {
  type = string
  default = "01"
}

variable "security_group_protocl_in" {
  type = string
  default = "tcp"
}

variable "security_group_protocl_e" {
  type = string
  default = "-1"
}

variable "security_group_rule_in" {
  type = string
  default = "ingress"
}

variable "all_port" {
  type = number
  default = 0
}

variable "db_port" {
  type = number
  default = 3306
}

variable "db_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "aws_security_group_ingress_port" {
  type = list(number)
  default = [22, 80, 443, 8080]
}

variable "security_group_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}

variable "destination" {
  type = string
  default = "0.0.0.0/0"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "azs" {
 type = list(string)
 default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# -------------------------------------------------------------------
# ec2 aws_security_group
variable "aws_security_group_app" {
  type = string
  default = "application"
}

variable "aws_security_group_app_desc" {
  type = string
  default = "security group for application"
}

# -------------------------------------------------------------------
# rds aws_security_group
variable "aws_security_group_db" {
  type = string
  default = "database"
}

variable "aws_security_group_db_desc" {
  type = string
  default = "security group for database"
}

# -------------------------------------------------------------------
# s3
variable "aws_s3_bucket_name" {
  type = string
  default = "webapp.jing.zhang"
}

variable "aws_s3_bucket_acl" {
  type = string
  default = "private"
}

variable "aws_s3_bucket_algorithm" {
  type = string
  default = "aws:kms"
}

variable "aws_s3_bucket_days" {
  type = number
  default = 30
}

variable "aws_s3_bucket_storage_class" {
  type = string
  default = "STANDARD_IA"
}

# -------------------------------------------------------------------
# iam
variable "aws_iam_policy_name" {
  type = string
  default = "WebAppS3"
}

variable "aws_iam_policy_path" {
  type = string
  default = "/"
}

variable "aws_iam_policy_description" {
  type = string
  default = "allow EC2 instances to perform S3 buckets"
}

variable "aws_iam_policy_policy" {
  type = string
  default = <<EOF
{"Version":"2012-10-17","Statement":[{"Action":["s3:CreateBucket","s3:ListBucket","s3:DeleteBucket","s3:GetObject","s3:PutObject","s3:DeleteObject","s3:GetObjectVersion","s3:GetBucketPolicy","s3:PutBucketPolicy","s3:GetBucketAcl","s3:PutBucketVersioning","s3:GetBucketVersioning","s3:PutLifecycleConfiguration","s3:GetLifecycleConfiguration","s3:DeleteBucketPolicy"],"Effect":"Allow","Resource":["arn:aws:s3:::webapp.jing.zhang","arn:aws:s3:::webapp.jing.zhang/*"]}]}
EOF
}

variable "aws_iam_role_name" {
  type = string
  default = "EC2-CSYE6225"
}

variable "aws_iam_role_assume_role_policy" {
  type = string
  default = <<EOF
{"Version":"2012-10-17","Statement":[{"Action":"sts:AssumeRole","Principal":{"Service":"ec2.amazonaws.com"},"Effect":"Allow","Sid":""}]}
  EOF
}

variable "aws_iam_policy_attachment_name" {
  type = string
  default = "attachment"
}

# -------------------------------------------------------------------
# aws_iam_instance_profile
variable "aws_iam_instance_profile_name" {
  type = string
  default = "profile"
}

# -------------------------------------------------------------------
# rds instance
variable "rds_engine" {
  type    = string
  default = "mysql"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "rds_identifier" {
  type    = string
  default = "csye6225-f20"
}

variable "rds_username" {
  type    = string
  default = "csye6225fall2020"
}

variable "password" {
  type    = string
  default = "MysqlPwd123"
}

variable "rds_publicly_accessible" {
  type    = bool
  default = false
}

variable "rds_name" {
  type    = string
  default = "csye6225"
}

variable "rds_engine_version" {
  type    = string
  default = "8.0.20"
}

variable "rds_allocated_storage" {
  type    = number
  default = 10
}

variable "aws_db_instance_final" {
  type    = string
  default = "foo"
}

# -------------------------------------------------------------------
# ssh key pair
variable "aws_key_pair_name" {
  type = string
  default = "ubuntu"
}

variable "aws_key_pair_key" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDoHTdtSqCFc+YCRHJvAFCVru2PmjePatrsuczKYGDP4E/9tNqOUTIZwiG7GYwFJ5Wchh9Ev9VNx6Nf+pfOVEHXSrSPm+9y2NXZYXdycxKrbB5MPb1MWYtb/WyOuwYCFukPVS/T9ctEa6De1NeHJ9xyiwo0yCGIh5YSneUBObxjNXFNE1j0d8lC2qJKyTvXubsI7E4sZp2GmvwNqKtGb1OgX7Eu/RFTdmbScpJ5xAQXYmvWWsK0dR5+40dX4wYtaD4K8ut1cRr6cixborLLhpCibYIKacrTIMIuiykREXj2inVcO7Ut/ZnGTl2uU/YdOgdqzH8zqknV6it7L6Iz5TLn martin@66.local"
}

# -------------------------------------------------------------------
# ec2 instance
variable "aws_iam_instance_profile_name" {
  type = string
  default = "instance_profile"
}

variable "ami_owner" {
  type = string
  default = "918834676735"
}

variable "aws_instance_instance_type" {
  type = string
  default = "t2.micro"
}

variable "aws_instance_volume_size" {
  type = number
  default = 20
}

variable "aws_instance_volume_type" {
  type = string
  default = "gp2"
}

variable "aws_instance_name" {
  type = string
  default = "ubuntu"
}

variable "user_data" {
  type = string
  default = <<EOF
#!/bin/bash
echo export DB_USERNAME="csye6225fall2020" >> /etc/profile
echo export DB_PASSWORD="MysqlPwd123" >> /etc/profile
echo export DB_NAME="csye6225" >> /etc/profile
echo export HOSTNAME=aws_db_instance.db.endpoint >> /etc/profile
echo export BUCKET_NAME="webapp.jing.zhang" >> /etc/profile
  EOF
}

# -------------------------------------------------------------------
# DNS record of ec2 public ip
variable "dns_a_record_zone" {
  type = string
  default = "api."+"${env.AWS_PROFILE}"+".bh7cw.me."
}

variable "dns_a_record_name" {
  type = string
  default = "dns_a_record_ec2_public_ip"
}

# -------------------------------------------------------------------
# dynamodb
variable "aws_dynamodb_table_name" {
  type = string
  default = "csye6225"
}

variable "aws_dynamodb_table_key" {
  type = string
  default = "id"
}

variable "aws_dynamodb_table_type" {
  type = string
  default = "S"
}

variable "aws_dynamodb_table_capacity" {
  type = number
  default = 2
}