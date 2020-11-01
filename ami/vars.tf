variable "region" {
  type = string
  default = "us-east-1"
}

# -------------------------------------------------------------------
# CodeDeploy-EC2-S3 policy

variable "aws_iam_codedeploy_ec2_s3_policy_name" {
  type = string
  default = "CodeDeploy-EC2-S3"
}

variable "aws_iam_codedeploy_ec2_s3_policy_description" {
  type = string
  default = "allows EC2 instances to read data from S3 buckets"
}

variable "aws_iam_codedeploy_ec2_s3_policy_content" {
  type = string
  default = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": [
              "*",
              "*"
              ]
        }
    ]
}
EOF
}

# GH-Upload-To-S3 policy
variable "aws_iam_gh_upload_to_s3_policy_name" {
  type = string
  default = "GH-Upload-To-S3"
}

variable "aws_iam_gh_upload_to_s3_policy_description" {
  type = string
  default = "allows GitHub Actions to upload artifacts from latest successful build to dedicated S3 bucket used by CodeDeploy"
}

variable "aws_iam_gh_upload_to_s3_policy_content" {
  type = string
  default = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

# GH-Code-Deploy policy
variable "aws_iam_gh-code-deploy-policy_name" {
  type = string
  default = "GH-Code-Deploy"
}

variable "aws_iam_gh-code-deploy-policy_description" {
  type = string
  default = "allows GitHub Actions to call CodeDeploy APIs to initiate application deployment on EC2 instances"
}

variable "aws_iam_gh-code-deploy-policy_content" {
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
        "arn:aws:codedeploy:us-east-1:918834676735:application:mywebapp"
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
}

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

variable "ghaction_user_name" {
  type = string
  default = "ghactions"
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

variable "aws_iam_policy_attachment_code_deploy_ec2_name" {
  type = string
  default = "code_deploy_iam_role_attach"
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