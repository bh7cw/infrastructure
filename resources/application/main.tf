provider "aws" {
  region = "us-east-1"
}

module "services" {
  source = "../../modules/securitygroup/application"

  vers = "01"
  aws_security_group_name = "application"
  aws_security_group_description = "security group for applicatio"
  region = "us-east-1"
}
