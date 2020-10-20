provider "aws" {
  region = "us-east-1"
}

#resource "aws_db_subnet_group" "_" {
#  name       = "subnet-group"
#  subnet_ids = [element(aws_subnet.subnet123.*.id, 1), element(aws_subnet.subnet123.*.id, 2)]
#}


resource "aws_db_instance" "db" {
  engine                  = var.rds_engine
  instance_class          = var.rds_instance_class
  multi_az                = var.multi_az
  identifier              = var.rds_identifier
  username                = var.rds_username
  password                = var.password
  #db_subnet_group_name    = 
  vpc_security_group_ids  = ["sg-0a925363c5a0830d8"]
  #["subnet-0ac4889a3f3979c6d","subnet-0dbf1724ee8ae73ef"]
  publicly_accessible     = var.rds_publicly_accessible
  name                    = var.rds_name
  engine_version          = var.rds_engine_version
  allocated_storage       = var.rds_allocated_storage

  #backup_retention_period = var.rds_backup_retention_period
  #backup_window           = var.rds_backup_window
  #maintenance_window      = var.rds_maintenance_window
  #port                    = var.rds_port
  #storage_encrypted       = var.rds_storage_encrypted
  #storage_type            = var.storage_type

  #vpc_security_group_ids = [aws_security_group.database.id]

  #allow_major_version_upgrade = false
  #auto_minor_version_upgrade  = true

  #final_snapshot_identifier = null
  #snapshot_identifier       = ""
  #skip_final_snapshot       = true

  #performance_insights_enabled = false
}
