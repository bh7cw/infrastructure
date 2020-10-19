provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "table" {
  name = "csye6225"
  hash_key = "id"
  read_capacity  = 2
  write_capacity = 2

  attribute {
    name = "id"
    type = "S"
  }
}
