provider "aws" {
  region = "us-east-1"
}

module "services" {
  source = "../../modules/vpc"

  vers = "01"
  region = "us-east-1"
}
