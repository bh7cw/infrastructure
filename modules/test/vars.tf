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