variable "rds_engine" {
  type    = string
  default = "mysql"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "rds_identifier" {
  type    = string
  default = "csye6225-f20"
}

variable "rds_username" {
  type    = string
  default = "csye6225fall2020"
}

variable "password" {
  type    = string
  default = "MysqlPwd123"
}

variable "rds_publicly_accessible" {
  type    = bool
  default = false
}

variable "rds_name" {
  type    = string
  default = "csye6225"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "rds_engine_version" {
  type    = string
  default = "8.0.20"
}

variable "rds_allocated_storage" {
  type    = number
  default = 10
}

variable "rds_storage_encrypted" {
  type    = bool
  default = false
}


variable "rds_port" {
  type    = number
  default = 3306
}
variable "rds_maintenance_window" {
  type    = string
  default = "Mon:00:00-Mon:03:00"
}
variable "rds_backup_window" {
  type    = string
  default = "10:46-11:16"
}
variable "rds_backup_retention_period" {
  type    = number
  default = 1
}
variable "rds_final_snapshot_identifier" {
  type    = string
  default = "prod-trademerch-website-db-snapshot"
}
variable "rds_snapshot_identifier" {
  type    = string
  default = null
}
variable "rds_performance_insights_enabled" {
  type    = bool
  default = true
}
variable "storage_type" {
  type    = string
  default = "gp2"
}
