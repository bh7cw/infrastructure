variable "region" {
  type = string
  default = "us-east-1"
}

# -------------------------------------------------------------------
# shared
variable "tbool" {
  type = bool
  default = true
}

variable "fbool" {
  type = bool
  default = false
}

# -------------------------------------------------------------------
# VPC
variable "vers" {
  type = string
  default = "01"
}

variable "security_group_protocl_in" {
  type = string
  default = "tcp"
}

variable "security_group_protocl_e" {
  type = string
  default = "-1"
}

variable "security_group_rule_in" {
  type = string
  default = "ingress"
}

variable "all_port" {
  type = number
  default = 0
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

variable "destination" {
  type = string
  default = "0.0.0.0/0"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "azs" {
 type = list(string)
 default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# -------------------------------------------------------------------
# ec2 aws_security_group
variable "aws_security_group_app" {
  type = string
  default = "application"
}

variable "aws_security_group_app_desc" {
  type = string
  default = "security group for application"
}

# -------------------------------------------------------------------
# rds aws_security_group
variable "aws_security_group_db" {
  type = string
  default = "database"
}

variable "aws_security_group_db_desc" {
  type = string
  default = "security group for database"
}

# -------------------------------------------------------------------
# Autoscaling Launch Configuration Security Group: WebAppSecurityGroup
variable "aws_autoscale_launch_config_security_group" {
  type = string
  default = "WebAppSecurityGroup"
}

variable "aws_autoscale_launch_config_security_group_desc" {
  type = string
  default = "security group for Autoscaling Launch Configuration"
}

# -------------------------------------------------------------------
# s3
variable "aws_s3_bucket_name" {
  type = string
  default = "webapp.jing.zhang"
}

variable "aws_s3_bucket_acl" {
  type = string
  default = "private"
}

variable "aws_s3_bucket_algorithm" {
  type = string
  default = "aws:kms"
}

variable "aws_s3_bucket_days" {
  type = number
  default = 30
}

variable "aws_s3_bucket_storage_class" {
  type = string
  default = "STANDARD_IA"
}

# -------------------------------------------------------------------
# iam
variable "aws_iam_policy_name" {
  type = string
  default = "WebAppS3"
}

variable "aws_iam_policy_path" {
  type = string
  default = "/"
}

variable "aws_iam_policy_description" {
  type = string
  default = "allow EC2 instances to perform S3 buckets"
}

variable "aws_iam_policy_policy" {
  type = string
  default = <<EOF
{"Version":"2012-10-17","Statement":[{"Action":["s3:CreateBucket","s3:ListBucket","s3:DeleteBucket","s3:GetObject","s3:PutObject","s3:DeleteObject","s3:GetObjectVersion","s3:GetBucketPolicy","s3:PutBucketPolicy","s3:GetBucketAcl","s3:PutBucketVersioning","s3:GetBucketVersioning","s3:PutLifecycleConfiguration","s3:GetLifecycleConfiguration","s3:DeleteBucketPolicy"],"Effect":"Allow","Resource":["arn:aws:s3:::webapp.jing.zhang","arn:aws:s3:::webapp.jing.zhang/*"]}]}
EOF
}

variable "aws_iam_role_name" {
  type = string
  default = "EC2-CSYE6225"
}

variable "aws_iam_role_assume_role_policy" {
  type = string
  default = <<EOF
{"Version":"2012-10-17","Statement":[{"Action":"sts:AssumeRole","Principal":{"Service":"ec2.amazonaws.com"},"Effect":"Allow","Sid":""}]}
  EOF
}

variable "aws_iam_policy_attachment_name" {
  type = string
  default = "attachment"
}

# -------------------------------------------------------------------
# codedeploy policies
// CodeDeploy-EC2-S3 policy
variable "aws_iam_codedeploy_ec2_s3_policy_name" {
  type = string
  default = "CodeDeploy-EC2-S3"
}

variable "aws_iam_codedeploy_ec2_s3_policy_description" {
  type = string
  default = "allows EC2 instances to read data from S3 buckets"
}

/*variable "aws_iam_codedeploy_ec2_s3_policy_content" {
  type = string
}*/

# GH-Upload-To-S3 policy
variable "aws_iam_gh_upload_to_s3_policy_name" {
  type = string
  default = "GH-Upload-To-S3"
}

variable "aws_iam_gh_upload_to_s3_policy_description" {
  type = string
  default = "allows GitHub Actions to upload artifacts from latest successful build to dedicated S3 bucket used by CodeDeploy"
}

/*variable "aws_iam_gh_upload_to_s3_policy_content" {
  type = string
}*/

# GH-Code-Deploy policy
variable "aws_iam_gh-code-deploy-policy_name" {
  type = string
  default = "GH-Code-Deploy"
}

variable "aws_iam_gh-code-deploy-policy_description" {
  type = string
  default = "allows GitHub Actions to call CodeDeploy APIs to initiate application deployment on EC2 instances"
}

/*variable "aws_iam_gh-code-deploy-policy_content" {
  type = string
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:us-east-1:918834676735:application:csye6225-webapp"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [
        "arn:aws:codedeploy:us-east-1:918834676735:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:us-east-1:918834676735:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:us-east-1:918834676735:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}*/

//gh-ec2-ami policy
variable "aws_iam_gh_ec2_ami_policy_name" {
  type = string
  default = "gh-ec2-ami"
}

variable "aws_iam_gh_ec2_ami_policy_description" {
  type = string
  default = "allows GitHub Actions to access to ec2"
}

variable "aws_iam_gh_ec2_ami_policy_content" {
  type = string
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

//ghactions changes to cicd
variable "ghaction_user_name" {
  type = string
  default = "cicd"
}

variable "aws_iam_policy_attachment_gh_upload_to_s3_name" {
  type = string
  default = "ghactions_attach_gh_upload_to_s3"
}

variable "aws_iam_policy_attachment_gh_code_deploy_name" {
  type = string
  default = "ghactions_attach_gh_code_deploy"
}

variable "aws_iam_policy_attachment_gh_ec2_ami_name" {
  type = string
  default = "ghactions_attach_gh_ec2_ami"
}

//CodeDeployEC2ServiceRole
variable "aws_code_deploy_iam_role_name" {
  type = string
  default = "CodeDeployEC2ServiceRole"
}

variable "aws_code_deploy_iam_role_assume_role_policy" {
  type = string
  default = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF
}

variable "aws_code_deploy_service_role_assume_role_policy" {
  type = string
  default = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "codedeploy.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
EOF
}

variable "aws_iam_policy_attachment_code_deploy_ec2_name" {
  type = string
  default = "code_deploy_iam_role_attach"
}

variable "attach_cloud_watch_policy_to_ec2_role_name" {
  type = string
  default = "cloud_watch_policy_to_ec2_role_attach"
}

//CodeDeployServiceRole
variable "aws_code_deploy_service_role_name" {
  type = string
  default = "code_deploy_service_role_attach"
}

variable "aws_code_deploy_role" {
  type = string
  default = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

variable "aws_iam_policy_attachment_code_deploy_service_name" {
  type = string
  default = "code_deploy_service_role_attach"
}

variable "attach_s3_to_ec2_attachment_name" {
  type = string
  default = "attach_s3_to_ec2_attachment"
}

# -------------------------------------------------------------------
# aws_iam_instance_profile
variable "aws_iam_instance_profile_name" {
  type = string
  default = "profile"
}

# -------------------------------------------------------------------
# rds instance
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

variable "rds_engine_version" {
  type    = string
  default = "8.0.20"
}

variable "rds_allocated_storage" {
  type    = number
  default = 10
}

variable "aws_db_instance_final" {
  type    = string
  default = "BAR"
}

# -------------------------------------------------------------------
# load balancer
variable "app_load_balancer_name" {
  type = string
  default = "app-load-balancer"
}

variable "app_load_balancer_type" {
  type = string
  default = "application"
}

# -------------------------------------------------------------------
# target group
variable "lb_target_group_name" {
  type = string
  default = "lb-target-group"
}

variable "lb_target_group_port" {
  type = string
  default = "8080"
}

# Application Load Balancer listener
variable "app_lb_listener_port" {
  type = string
  default = "80"
}

variable "app_load_balancer_protocol" {
  type = string
  default = "HTTP"
}

variable "app_load_balancer_action_type" {
  type = string
  default = "forward"
}

variable "app_load_balancer_action_redirect_path" {
  type = string
  default = "/"
}

variable "app_load_balancer_action_redirect_port" {
  type = string
  default = "8080"
}

variable "app_load_balancer_action_redirect_code" {
  type = string
  default = "HTTP_301"
}

# -------------------------------------------------------------------
# ssh key pair
variable "aws_key_pair_name" {
  type = string
  default = "ubuntu"
}

variable "aws_key_pair_key" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDoHTdtSqCFc+YCRHJvAFCVru2PmjePatrsuczKYGDP4E/9tNqOUTIZwiG7GYwFJ5Wchh9Ev9VNx6Nf+pfOVEHXSrSPm+9y2NXZYXdycxKrbB5MPb1MWYtb/WyOuwYCFukPVS/T9ctEa6De1NeHJ9xyiwo0yCGIh5YSneUBObxjNXFNE1j0d8lC2qJKyTvXubsI7E4sZp2GmvwNqKtGb1OgX7Eu/RFTdmbScpJ5xAQXYmvWWsK0dR5+40dX4wYtaD4K8ut1cRr6cixborLLhpCibYIKacrTIMIuiykREXj2inVcO7Ut/ZnGTl2uU/YdOgdqzH8zqknV6it7L6Iz5TLn martin@66.local"
}

# -------------------------------------------------------------------
# ec2 instance
variable "aws_iam_ec2_instance_profile_name" {
  type = string
  default = "instance_profile"
}

variable "ami_owner" {
  type = string
  default = "918834676735"
}

variable "aws_instance_instance_type" {
  type = string
  default = "t2.micro"
}

variable "aws_instance_volume_size" {
  type = number
  default = 20
}

variable "aws_instance_volume_type" {
  type = string
  default = "gp2"
}

variable "aws_instance_name" {
  type = string
  default = "ubuntu"
}

variable "user_data" {
  type = string
  default = <<EOF
#!/bin/bash
echo export DB_USERNAME="csye6225fall2020" >> /etc/profile
echo export DB_PASSWORD="MysqlPwd123" >> /etc/profile
echo export DB_NAME="csye6225" >> /etc/profile
echo export DBHOSTNAME=aws_db_instance.db.endpoint >> /etc/profile
echo export BUCKET_NAME="webapp.jing.zhang" >> /etc/profile
  EOF
}

# -------------------------------------------------------------------
# Autoscaling Launch Configuration for EC2 Instances
variable "aws_launch_configuration_name" {
  type = string
  default = "asg_launch_config"
}

# -------------------------------------------------------------------
# Autoscaling group
variable "aws_autoscaling_group_name" {
  type = string
  default = "aws_autoscaling_group"
}

variable "aws_autoscaling_group_tag_key" {
  type = string
  default = "Name"
}

variable "aws_autoscaling_group_tag_value" {
  type = string
  default = "ubuntu"
}

# -------------------------------------------------------------------
# Autoscaling group scale up policy
variable "aws_autoscaling_scale_up_policy_name" {
  type = string
  default = "WebServerScaleUpPolicy"
}

variable "aws_autoscaling_scale_up_policy_scaling_adjustment" {
  type = number
  default = 1
}

variable "aws_autoscaling_scale_up_policy_adjustment_type" {
  type = string
  default = "ChangeInCapacity"
}

variable "aws_autoscaling_scale_up_policy_cooldown" {
  type = number
  default = 60
}

# -------------------------------------------------------------------
# Autoscaling group scale down policy
variable "aws_autoscaling_scale_down_policy_name" {
  type = string
  default = "WebServerScaleDownPolicy"
}

variable "aws_autoscaling_scale_down_policy_scaling_adjustment" {
  type = number
  default = -1
}

# -------------------------------------------------------------------
# cloud watch alarm for Autoscaling group scale up policy
variable "cloudwatch_scale_up_alarm_name" {
  type = string
  default = "CPUAlarmHigh"
}

variable "cloudwatch_scale_up_alarm_description" {
  type = string
  default = "Scale-up if CPU > 5% for 2 minutes"
}

variable "cloudwatch_scale_up_alarm_metric_name" {
  type = string
  default = "CPUUtilization"
}

variable "cloudwatch_scale_up_alarm_namespace" {
  type = string
  default = "AWS/EC2"
}

variable "cloudwatch_scale_up_alarm_statistic" {
  type = string
  default = "Average"
}

variable "cloudwatch_scale_up_alarm_period" {
  type = number
  default = 60
}

variable "cloudwatch_scale_up_alarm_evaluation_periods" {
  type = number
  default = 2
}

variable "cloudwatch_scale_up_alarm_threshold" {
  type = number
  default = 5
}

variable "cloudwatch_scale_up_alarm_comparison_operator" {
  type = string
  default = "GreaterThanThreshold"
}

# -------------------------------------------------------------------
# cloud watch alarm for Autoscaling group scale down policy
variable "cloudwatch_scale_down_alarm_name" {
  type = string
  default = "CPUAlarmLow"
}

variable "cloudwatch_scale_down_alarm_description" {
  type = string
  default = "Scale-down if CPU < 3% for 2 minutes"
}

variable "cloudwatch_scale_down_alarm_period" {
  type = number
  default = 60
}

variable "cloudwatch_scale_down_alarm_evaluation_periods" {
  type = number
  default = 2
}

variable "cloudwatch_scale_down_alarm_threshold" {
  type = number
  default = 3
}

variable "cloudwatch_scale_down_alarm_comparison_operator" {
  type = string
  default = "LessThanThreshold"
}

# -------------------------------------------------------------------
# DNS record of ec2 public ip
variable "hostedzone" {
  type = string
  default = "dev.bh7cw.me"
}

variable "env" {
  type = string
  //default = "dev"
}

/*variable "dns_a_record_name" {
  type = string
  //default = "${var.dns_a_record_name_api}.${var.environment}.${var.dns_a_record_name_domain}.${var.dns_a_record_name_tld}."
}*/

variable "dns_a_record_type" {
  type = string
  default = "A"
}

variable "dns_a_record_ttl" {
  type = string
  default = "60"
}

# -------------------------------------------------------------------
# Create CodeDeploy Application
variable "codedeploy_app_name" {
  type = string
  default = "csye6225-webapp"
}

variable "codedeploy_app_cp" {
  type = string
  default = "Server"
}

# -------------------------------------------------------------------
# Create CodeDeploy Deployment Group
variable "codedeploy_deployment_group_name" {
  type = string
  default = "csye6225-webapp-deployment"
}

variable "codedeploy_deployment_group_deployment_style" {
  type = string
  default = "IN_PLACE"
}

variable "codedeploy_deployment_group_deployment_config_name" {
  type = string
  default = "CodeDeployDefault.AllAtOnce"
}

variable "codedeploy_deployment_group_ec2_tag_filter_key" {
  type = string
  default = "Name"
}

variable "codedeploy_deployment_group_ec2_tag_filter_type" {
  type = string
  default = "KEY_AND_VALUE"
}

variable "codedeploy_deployment_group_ec2_tag_filter_value" {
  type = string
  default = "ubuntu"
}

# -------------------------------------------------------------------
# dynamodb
variable "aws_dynamodb_table_name" {
  type = string
  default = "csye6225"
}

variable "aws_dynamodb_table_key" {
  type = string
  default = "id"
}

variable "aws_dynamodb_table_type" {
  type = string
  default = "S"
}

variable "aws_dynamodb_table_capacity" {
  type = number
  default = 2
}