provider "aws" {
  region = "us-east-1"
}

module "services" {
  source = "../modules/ec2ins"

  #bucket_name = "webapp.jing.zhang"
  user_data = "#!/bin/bash\necho 'hello world'\nsudo hostname ubuntu\nexport DB_USERNAME=root\nexport DB_PASSWORD=MysqlPwd123\nexport Bucket_Name=webapp.jing.zhang"
}
