provider "aws" {
  region = "us-east-1"
}

module "services" {
  source = "../../modules/services"

  vers = "03"
  region = "us-east-1"
}
