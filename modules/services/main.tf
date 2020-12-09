provider "aws" {
  region = var.region
}

# -------------------------------------------------------------------
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.tbool
  enable_dns_support   = var.tbool
  enable_classiclink_dns_support = var.tbool
  assign_generated_ipv6_cidr_block = var.fbool
  tags = {
    Name = "vpc-${var.vers}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igt-${var.vers}"
  }
}

# subnet
resource "aws_subnet" "subnet123" {
  count = length(var.subnet_cidr_block)
  cidr_block           = element(var.subnet_cidr_block,count.index)
  vpc_id = aws_vpc.vpc.id
  availability_zone    = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-${var.vers}-${count.index}"
  }
}


# Route table: attach Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.destination
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "rt-${var.vers}"
  }
}

# Route table association with public subnets
resource "aws_route_table_association" "a" {
  count = length(var.subnet_cidr_block)
  subnet_id      = element(aws_subnet.subnet123.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}

/* WebAppSecurityGroup is for auto-scaling, while application is for ec2
we are using auto-scaling instead of ec2, so comment here
# -------------------------------------------------------------------
# ec2 aws_security_group
resource "aws_security_group" "application" {
  name        = var.aws_security_group_app
  description = var.aws_security_group_app_desc
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = var.all_port
    to_port     = var.all_port
    protocol    = var.security_group_protocl_e
    cidr_blocks = [var.security_group_cidr_block]
  }

  tags = {
    Name = var.aws_security_group_app
  }
}

resource "aws_security_group_rule" "applicationsgr" {
  count             = length(var.aws_security_group_ingress_port)
  type              = var.security_group_rule_in
  from_port         = element(var.aws_security_group_ingress_port,count.index)
  to_port           = element(var.aws_security_group_ingress_port,count.index)
  protocol          = var.security_group_protocl_in
  cidr_blocks       = [var.security_group_cidr_block]
  security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "applicationsgr2" {
  type              = var.security_group_rule_in
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = var.security_group_protocl_in
  cidr_blocks       = [var.db_cidr_block]
  security_group_id = aws_security_group.application.id
}
*/

# -------------------------------------------------------------------
# load balancer aws_security_group
resource "aws_security_group" "load_balancer" {
  name        = "security-group-lb"
  description = "only allow 80 for ingress"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = var.all_port
    to_port     = var.all_port
    protocol    = var.security_group_protocl_e
    cidr_blocks = [var.security_group_cidr_block]
  }
}

resource "aws_security_group_rule" "lb_sgr" {
  count             = length(var.aws_security_group_lb_ingress_port)
  type              = var.security_group_rule_in
  from_port         = element(var.aws_security_group_lb_ingress_port,count.index)
  to_port           = element(var.aws_security_group_lb_ingress_port,count.index)
  protocol          = var.security_group_protocl_in
  cidr_blocks       = [var.security_group_cidr_block]
  security_group_id = aws_security_group.load_balancer.id
}

# -------------------------------------------------------------------
# Autoscaling Launch Configuration Security Group: WebAppSecurityGroup
resource "aws_security_group" "autoscale_launch_config" {
  name        = var.aws_autoscale_launch_config_security_group
  description = var.aws_security_group_app_desc
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = var.all_port
    to_port     = var.all_port
    protocol    = var.security_group_protocl_e
    cidr_blocks = [var.security_group_cidr_block]
  }

  tags = {
    Name = var.aws_autoscale_launch_config_security_group
  }
}

resource "aws_security_group_rule" "autoscale_launch_config_sgr" {
  count             = length(var.aws_security_group_ingress_port)
  type              = var.security_group_rule_in
  from_port         = element(var.aws_security_group_ingress_port,count.index)
  to_port           = element(var.aws_security_group_ingress_port,count.index)
  protocol          = var.security_group_protocl_in
  #cidr_blocks       = [var.security_group_cidr_block]
  security_group_id = aws_security_group.autoscale_launch_config.id
  #security_groups   = [aws_security_group.load_balancer.id]
  source_security_group_id  = aws_security_group.load_balancer.id
}

//check later
/*resource "aws_security_group_rule" "autoscale_launch_config_sgr2" {
  type              = var.security_group_rule_in
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = var.security_group_protocl_in
  cidr_blocks       = [var.db_cidr_block]
  security_group_id = aws_security_group.autoscale_launch_config.id
}*/

# -------------------------------------------------------------------
# rds aws_security_group
resource "aws_security_group" "database" {
  name        = var.aws_security_group_db
  description = var.aws_security_group_db_desc
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = var.security_group_protocl_in
    security_groups = [aws_security_group.autoscale_launch_config.id]
    //check later
    #cidr_blocks     = [var.db_cidr_block]
  }

  egress {
    from_port   = var.all_port
    to_port     = var.all_port
    protocol    = var.security_group_protocl_e
    cidr_blocks = [var.security_group_cidr_block]
  }

  tags = {
    Name = var.aws_security_group_db
  }
}

# -------------------------------------------------------------------
# s3
resource "aws_s3_bucket" "b" {
  bucket = var.aws_s3_bucket_name
  force_destroy = var.tbool
  acl    = var.aws_s3_bucket_acl
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.aws_s3_bucket_algorithm
      }
    }
  }

  lifecycle_rule {
    enabled = var.tbool

    noncurrent_version_transition {
      days          = var.aws_s3_bucket_days
      storage_class = var.aws_s3_bucket_storage_class
    }
  }

  tags = {
    Name        = var.aws_s3_bucket_name
  }
}

# -------------------------------------------------------------------
# iam
resource "aws_iam_policy" "policy" {
  name        = var.aws_iam_policy_name
  path        = var.aws_iam_policy_path
  description = var.aws_iam_policy_description

  policy = var.aws_iam_policy_policy
}

resource "aws_iam_role" "role" {
  name = var.aws_iam_role_name
  assume_role_policy = var.aws_iam_role_assume_role_policy
}

resource "aws_iam_policy_attachment" "attach" {
  name       = var.aws_iam_policy_attachment_name
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}

# -------------------------------------------------------------------
# codedeploy plocies
//CodeDeploy-EC2-S3 policy
data "aws_s3_bucket" "codedeploy_bucket" {
  bucket = format("codedeploy.%s.bh7cw.me", var.env)//"codedeploy.dev.bh7cw.me"
}

resource "aws_iam_policy" "codedeploy-ec2-s3-policy" {
  name        = var.aws_iam_codedeploy_ec2_s3_policy_name
  description = var.aws_iam_codedeploy_ec2_s3_policy_description
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
              "${data.aws_s3_bucket.codedeploy_bucket.arn}",
              "${data.aws_s3_bucket.codedeploy_bucket.arn}/*"
            ]
        }
    ]
}
EOF
}

//GH-Upload-To-S3 policy
resource "aws_iam_policy" "gh-upload-to-s3-policy" {
  name        = var.aws_iam_gh_upload_to_s3_policy_name
  description = var.aws_iam_gh_upload_to_s3_policy_description
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "${data.aws_s3_bucket.codedeploy_bucket.arn}",
                "${data.aws_s3_bucket.codedeploy_bucket.arn}/*"
            ]
        }
    ]
}
EOF
}

//GH-Code-Deploy policy
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "gh-code-deploy-policy" {
  name        = var.aws_iam_gh-code-deploy-policy_name
  description = var.aws_iam_gh-code-deploy-policy_description
  policy      = <<EOF
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
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:application:${var.codedeploy_app_name}"
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
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime",
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.HalfAtATime",
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
EOF
}

//gh-ec2-ami policy
resource "aws_iam_policy" "gh-ec2-ami-policy" {
  name        = var.aws_iam_gh_ec2_ami_policy_name
  description = var.aws_iam_gh_ec2_ami_policy_description
  policy      = var.aws_iam_gh_ec2_ami_policy_content
}

//attach GH-Upload-To-S3 policy to `ghaction` user
resource "aws_iam_policy_attachment" "attach1" {
  name       = var.aws_iam_policy_attachment_gh_upload_to_s3_name
  users      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-upload-to-s3-policy.arn
}

//attach GH-Code-Deploy policy to `ghaction` user
resource "aws_iam_policy_attachment" "attach2" {
  name       = var.aws_iam_policy_attachment_gh_code_deploy_name
  users      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-code-deploy-policy.arn
}

//attach gh-ec2-ami policy to `ghaction` user
/*resource "aws_iam_policy_attachment" "attach3" {
  name       = var.aws_iam_policy_attachment_gh_ec2_ami_name
  users      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-ec2-ami-policy.arn
}*/

//CodeDeployEC2ServiceRole
resource "aws_iam_role" "code_deploy_ec2_role" {
  name = var.aws_code_deploy_iam_role_name
  assume_role_policy = var.aws_code_deploy_iam_role_assume_role_policy
}

//attach aws_iam_role policy to `CodeDeployEC2ServiceRole` role
resource "aws_iam_policy_attachment" "attach_code_deploy_ec2_role" {
  name       = var.aws_iam_policy_attachment_code_deploy_ec2_name
  roles      = [aws_iam_role.code_deploy_ec2_role.name]
  policy_arn = aws_iam_policy.codedeploy-ec2-s3-policy.arn
}

//attach WebAppS3 policy to `CodeDeployEC2ServiceRole` role
resource "aws_iam_policy_attachment" "attach_s3_to_ec2" {
  name       = var.attach_s3_to_ec2_attachment_name
  roles      = [aws_iam_role.code_deploy_ec2_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

//attach CloudWatchAgentServerPolicy to `CodeDeployEC2ServiceRole` role
resource "aws_iam_policy_attachment" "attach_cloud_watch_policy_to_ec2_role" {
  name       = var.attach_cloud_watch_policy_to_ec2_role_name
  roles      = [aws_iam_role.code_deploy_ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

//ssn-publish-message policy
resource "aws_iam_policy" "ssn-publish-message-policy" {
  name        = "policy_sns_publish_message"
  description = "allow to publish message in sns"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "sns:Publish"
          ],
          "Resource": [
              "arn:aws:sns:us-east-1:907204364947:topic"
          ]
      }
  ]
}
EOF
}

//attach ssn-publish-message to `CodeDeployEC2ServiceRole` role
resource "aws_iam_policy_attachment" "attach_sns_publish_policy_to_ec2_role" {
  name       = "attach_sns_publish_policy_to_ec2_role"
  roles      = [aws_iam_role.code_deploy_ec2_role.name]
  policy_arn = aws_iam_policy.ssn-publish-message-policy.arn
}

//CodeDeployServiceRole
resource "aws_iam_role" "code_deploy_service_role" {
  name = var.aws_code_deploy_service_role_name
  assume_role_policy = var.aws_code_deploy_service_role_assume_role_policy
}

resource "aws_iam_policy_attachment" "attach_code_deploy_service_role" {
  name       = var.aws_iam_policy_attachment_code_deploy_service_name
  roles      = [aws_iam_role.code_deploy_service_role.name]
  policy_arn = var.aws_code_deploy_role
}

# -------------------------------------------------------------------
# aws_iam_instance_profile
resource "aws_iam_instance_profile" "profile" {
  name = var.aws_iam_instance_profile_name
  role = aws_iam_role.role.name
}

# -------------------------------------------------------------------
# ssl certificate
# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain   = format("%s.bh7cw.me", var.env)
  statuses = ["ISSUED"]
}

# -------------------------------------------------------------------
# rds instance parameter_group
resource "aws_db_parameter_group" "pg" {
  name   = "pg"
  family = "mysql8.0"

  parameter {
    apply_method = "immediate"
    #"pending-reboot"
    name         = "performance_schema"
    value        = "1"
  }
}

# -------------------------------------------------------------------
# rds instance
resource "aws_db_subnet_group" "_" {
  #name       = "aws-subnet-group"
  subnet_ids = [element(aws_subnet.subnet123.*.id, 1), element(aws_subnet.subnet123.*.id, 2)]
}

resource "aws_db_instance" "db" {
  engine                  = var.rds_engine
  instance_class          = var.rds_instance_class
  multi_az                = var.multi_az
  identifier              = var.rds_identifier
  username                = var.rds_username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group._.id
  vpc_security_group_ids  = [aws_security_group.database.id]
  publicly_accessible     = var.rds_publicly_accessible
  name                    = var.rds_name
  engine_version          = var.rds_engine_version
  allocated_storage       = var.rds_allocated_storage
  #final_snapshot_identifier = var.aws_db_instance_final
  final_snapshot_identifier = null
  snapshot_identifier       = ""
  skip_final_snapshot       = true
  apply_immediately         = true
  storage_encrypted         = true
  ca_cert_identifier        = "rds-ca-2019"
  parameter_group_name      = aws_db_parameter_group.pg.id

  #backup_retention_period = var.rds_backup_retention_period
  #backup_window           = var.rds_backup_window
  #maintenance_window      = var.rds_maintenance_window
  #port                    = var.rds_port
  #storage_encrypted       = var.rds_storage_encrypted
  #storage_type            = var.storage_type
  #allow_major_version_upgrade = false
  #auto_minor_version_upgrade  = true
  #performance_insights_enabled = true
}

# -------------------------------------------------------------------
# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = var.app_load_balancer_name
  internal           = var.fbool
  load_balancer_type = var.app_load_balancer_type
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.subnet123.*.id
}

# -------------------------------------------------------------------
# target group
resource "aws_lb_target_group" "lb_target_group" {
  name     = var.lb_target_group_name
  port     = var.lb_target_group_port
  protocol = var.app_load_balancer_protocol
  vpc_id   = aws_vpc.vpc.id
  health_check{
    path     = "/v1/users"
    port     = 8080
    interval = 300
  }
}

# Application Load Balancer listener: http-80
/*resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.app_lb_listener_port
  protocol          = var.app_load_balancer_protocol

  default_action {
    type             = var.app_load_balancer_action_type
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}*/

# Application Load Balancer listener: https-443
resource "aws_lb_listener" "app_lb_listener_https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = var.app_load_balancer_action_type
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# -------------------------------------------------------------------
# ssh key pair
resource "aws_key_pair" "ssh" {
  key_name   = var.aws_key_pair_name
  public_key = var.aws_key_pair_key
}

# -------------------------------------------------------------------
# ec2 instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = var.aws_iam_ec2_instance_profile_name
  role = aws_iam_role.code_deploy_ec2_role.name
}

data "aws_ami" "ami" {
  most_recent = var.tbool
  owners = [var.ami_owner]
}

/*resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ami.id
  instance_type               = var.aws_instance_instance_type
  vpc_security_group_ids      = [aws_security_group.application.id]
  subnet_id                   = element(aws_subnet.subnet123.*.id,0)
  disable_api_termination     = var.fbool
  #iam_instance_profile        = aws_iam_instance_profile.profile.name
  key_name                    = aws_key_pair.ssh.id
  iam_instance_profile       = aws_iam_instance_profile.instance_profile.name

  user_data                   = <<EOF
#!/bin/bash
echo DB_USERNAME="${var.rds_username}" >> /etc/environment
echo DB_PASSWORD="${var.password}" >> /etc/environment
echo DB_NAME="${var.aws_dynamodb_table_name}" >> /etc/environment
echo DBHOSTNAME="${aws_db_instance.db.endpoint}" >> /etc/environment
echo BUCKET_NAME="${var.aws_s3_bucket_name}" >> /etc/environment
  EOF

  connection {
    user = var.aws_instance_name
    host = aws_instance.ubuntu.public_ip
  }
  
  root_block_device {
    delete_on_termination     = var.tbool
    volume_size               = var.aws_instance_volume_size
    volume_type               = var.aws_instance_volume_type
  } 

  tags = {
    Name = var.aws_instance_name
  }
}*/

# -------------------------------------------------------------------
# Autoscaling Launch Configuration for EC2 Instances
resource "aws_launch_configuration" "aws_conf" {
  name          = var.aws_launch_configuration_name
  image_id      = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name                    = aws_key_pair.ssh.id
  associate_public_ip_address = var.tbool
  user_data                   = <<EOF
#!/bin/bash
echo DB_USERNAME="${var.rds_username}" >> /etc/environment
echo DB_PASSWORD="${var.password}" >> /etc/environment
echo DB_NAME="${var.aws_dynamodb_table_name}" >> /etc/environment
echo DBHOSTNAME="${aws_db_instance.db.endpoint}" >> /etc/environment
echo BUCKET_NAME="${var.aws_s3_bucket_name}" >> /etc/environment
  EOF

  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
  security_groups             = [aws_security_group.autoscale_launch_config.id]

  root_block_device {
    volume_type            = "gp2"
    volume_size            = 20
    delete_on_termination  = true
  }
}

# -------------------------------------------------------------------
# Autoscaling group
resource "aws_autoscaling_group" "aws_autoscale_gr" {
  name                      = var.aws_autoscaling_group_name
  default_cooldown          = 60
  launch_configuration      = aws_launch_configuration.aws_conf.name
  health_check_grace_period = 300
  health_check_type         = "EC2"
  max_size                  = 5
  min_size                  = 3
  desired_capacity          = 3
  vpc_zone_identifier       = aws_subnet.subnet123.*.id

  tag {
    key                     = var.aws_autoscaling_group_tag_key
    value                   = var.aws_autoscaling_group_tag_value
    propagate_at_launch     = var.tbool
  }

  target_group_arns         = [aws_lb_target_group.lb_target_group.arn]
}

# -------------------------------------------------------------------
# Autoscaling group scale up policy
resource "aws_autoscaling_policy" "autoscaling_scale_up_policy" {
  name                   = var.aws_autoscaling_scale_up_policy_name
  scaling_adjustment     = var.aws_autoscaling_scale_up_policy_scaling_adjustment
  adjustment_type        = var.aws_autoscaling_scale_up_policy_adjustment_type
  cooldown               = var.aws_autoscaling_scale_up_policy_cooldown
  autoscaling_group_name = aws_autoscaling_group.aws_autoscale_gr.name
}

# -------------------------------------------------------------------
# cloud watch alarm for Autoscaling group scale up policy
resource "aws_cloudwatch_metric_alarm" "cloudwatch_scale_up_alarm" {
  alarm_name          = var.cloudwatch_scale_up_alarm_name
  alarm_description   = var.cloudwatch_scale_up_alarm_description
  metric_name         = var.cloudwatch_scale_up_alarm_metric_name
  namespace           = var.cloudwatch_scale_up_alarm_namespace
  statistic           = var.cloudwatch_scale_up_alarm_statistic
  period              = var.cloudwatch_scale_up_alarm_period
  evaluation_periods  = "10"
  threshold           = var.cloudwatch_scale_up_alarm_threshold
  alarm_actions       = [aws_autoscaling_policy.autoscaling_scale_up_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aws_autoscale_gr.name
  }
  comparison_operator = var.cloudwatch_scale_up_alarm_comparison_operator
}

# -------------------------------------------------------------------
# Autoscaling group scale down policy
resource "aws_autoscaling_policy" "autoscaling_scale_down_policy" {
  name                   = var.aws_autoscaling_scale_down_policy_name
  scaling_adjustment     = var.aws_autoscaling_scale_down_policy_scaling_adjustment
  adjustment_type        = var.aws_autoscaling_scale_up_policy_adjustment_type
  cooldown               = var.aws_autoscaling_scale_up_policy_cooldown
  autoscaling_group_name = aws_autoscaling_group.aws_autoscale_gr.name
}

# -------------------------------------------------------------------
# cloud watch alarm for Autoscaling group scale down policy
resource "aws_cloudwatch_metric_alarm" "cloudwatch_scale_down_alarm" {
  alarm_name          = var.cloudwatch_scale_down_alarm_name
  alarm_description   = var.cloudwatch_scale_down_alarm_description
  metric_name         = var.cloudwatch_scale_up_alarm_metric_name
  namespace           = var.cloudwatch_scale_up_alarm_namespace
  statistic           = var.cloudwatch_scale_up_alarm_statistic
  period              = var.cloudwatch_scale_up_alarm_period
  evaluation_periods  = "10"
  threshold           = var.cloudwatch_scale_down_alarm_threshold
  alarm_actions       = [aws_autoscaling_policy.autoscaling_scale_down_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aws_autoscale_gr.name
  }
  comparison_operator = var.cloudwatch_scale_down_alarm_comparison_operator
}

# -------------------------------------------------------------------
# DNS record of ec2 public ip
data "aws_route53_zone" "selected" {
  name         = format("%s.bh7cw.me", var.env)
  private_zone = var.fbool
}

/*resource "aws_route53_record" "dns_a_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = format("api.%s.bh7cw.me.", var.env)
  type    = var.dns_a_record_type
  #ttl     = var.dns_a_record_ttl
  #records = [aws_instance.ubuntu.public_ip]
  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = var.tbool
  }
}*/

resource "aws_route53_record" "lb_alias_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = format("%s.bh7cw.me.", var.env)
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = var.fbool
  }
}

# -------------------------------------------------------------------
# Create CodeDeploy Application
resource "aws_codedeploy_app" "codedeploy_app" {
  compute_platform = var.codedeploy_app_cp
  name             = var.codedeploy_app_name
}

# -------------------------------------------------------------------
# Create CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = var.codedeploy_deployment_group_name
  service_role_arn      = aws_iam_role.code_deploy_service_role.arn
  deployment_config_name = var.codedeploy_deployment_group_deployment_config_name

  deployment_style {
    deployment_type = var.codedeploy_deployment_group_deployment_style
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = var.codedeploy_deployment_group_ec2_tag_filter_key
      type  = var.codedeploy_deployment_group_ec2_tag_filter_type
      value = var.codedeploy_deployment_group_ec2_tag_filter_value
    }
  }

  /*trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "example-trigger"
    trigger_target_arn = aws_sns_topic.example.arn
  }*/

  auto_rollback_configuration {
    enabled = var.fbool
    # events  = ["DEPLOYMENT_FAILURE"]
  }
}

# -------------------------------------------------------------------
# dynamodb
resource "aws_dynamodb_table" "table" {
  name = var.aws_dynamodb_table_name
  hash_key = var.aws_dynamodb_table_key
  read_capacity  = var.aws_dynamodb_table_capacity
  write_capacity = var.aws_dynamodb_table_capacity

  attribute {
    name = var.aws_dynamodb_table_key
    type = var.aws_dynamodb_table_type
  }
}

# -------------------------------------------------------------------
# sns topic
resource "aws_sns_topic" "sns_topic" {
  name = "topic"
}

# -------------------------------------------------------------------
# lambda basic execution role
resource "aws_iam_role" "lambda_basic_execution_role" {
  name = "lambda_basic_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:*",
                "ses:*",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

//attach aws_iam_role policy to lambda basic execution role
resource "aws_iam_policy_attachment" "attach_ses_db_lambda_basic_execution_role" {
  name       = "attach_ses_dynomodb_lambda_basic_execution_role"
  roles      = [aws_iam_role.lambda_basic_execution_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# -------------------------------------------------------------------
# lambda function
resource "aws_lambda_function" "lambda_func" {
  #filename      = "function.zip"
  function_name = "CDFunc"
  role          = aws_iam_role.lambda_basic_execution_role.arn
  handler       = "main"
  s3_bucket     = format("codedeploy.%s.bh7cw.me", var.env)
  s3_key        = "function.zip"

  #source_code_hash = filebase64sha256("function.zip")

  runtime = "go1.x"
}

# -------------------------------------------------------------------
# add sns trigger to lambda
resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns_topic.arn
}

# -------------------------------------------------------------------
# add sns subscription to lambda
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn            = aws_sns_topic.sns_topic.arn
  protocol             = "lambda"
  endpoint             = aws_lambda_function.lambda_func.arn
}

# -------------------------------------------------------------------
# attach GH-Upload-To-S3 policy to `cicd_lambda` user
resource "aws_iam_policy_attachment" "cicd_lambda_attach1" {
  name       = "policy_attachment_s3_cicd_lambda_name"
  users      = ["cicd_lambda"]
  policy_arn = aws_iam_policy.gh-upload-to-s3-policy.arn
}

# -------------------------------------------------------------------
# create aws_deploy_lambda policy
resource "aws_iam_policy" "aws-deploy-lambda-policy" {
  name        = "aws_deploy_lambda_policy"
  description = "allow aws cli to deploy lambda application"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "lambda:UpdateFunctionCode"
          ],
          "Resource": [
              "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:CDFunc"
          ]
      }
  ]
}
EOF
}

# -------------------------------------------------------------------
# attach aws_deploy_lambda policy to `cicd_lambda` user
resource "aws_iam_policy_attachment" "cicd_lambda_attach2" {
  name       = "policy_attachment_aws_cicd_lambda_name"
  users      = ["cicd_lambda"]
  policy_arn = aws_iam_policy.aws-deploy-lambda-policy.arn
}