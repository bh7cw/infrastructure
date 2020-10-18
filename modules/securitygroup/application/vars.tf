variable "vers" {
  type = string
}

variable "aws_security_group_name" {
  type = string
}

variable "aws_security_group_description" {
  type = string
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

variable "region" {
  type = string
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
  type = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "azs" {
 type = "list"
 default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
