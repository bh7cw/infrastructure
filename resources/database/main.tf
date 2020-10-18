provider "aws" {
  region = "us-east-1"
}

module "services" {
  source = "../../modules/SecurityGroup/database"

  vers = "01"
  aws_security_group_name = "database"
  aws_security_group_description = "security group for database instance"
  region = "us-east-1"
}
