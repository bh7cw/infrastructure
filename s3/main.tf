provider "aws" {
  region = "us-east-1"
}

module "services" {
  source = "../modules/s3"

  bucket_name = "webapp.jing.zhang"
}
