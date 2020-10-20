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
{"Version":"2012-10-17","Statement":[{"Action":["s3:*"],"Effect":"Allow","Resource":["arn:aws:s3:::webapp.jing.zhang","arn:aws:s3:::webapp.jing.zhang/*"]}]}
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
# ec2 instance
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
  default = "#!/bin/bash\necho 'hello world'\nexport DB_USERNAME=root\nexport DB_PASSWORD=MysqlPwd123\nexport Bucket_Name=webapp.jing.zhang"
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