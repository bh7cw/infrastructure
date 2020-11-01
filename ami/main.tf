provider "aws" {
  region = var.region
}

//CodeDeploy-EC2-S3 policy
resource "aws_iam_policy" "codedeploy-ec2-s3-policy" {
  name        = var.aws_iam_codedeploy_ec2_s3_policy_name
  description = var.aws_iam_codedeploy_ec2_s3_policy_description
  policy      = var.aws_iam_codedeploy_ec2_s3_policy_content
}

//GH-Upload-To-S3 policy
resource "aws_iam_policy" "gh-upload-to-s3-policy" {
  name        = var.aws_iam_gh_upload_to_s3_policy_name
  description = var.aws_iam_gh_upload_to_s3_policy_description
  policy      = var.aws_iam_gh_upload_to_s3_policy_content
}

//GH-Code-Deploy policy
resource "aws_iam_policy" "gh-code-deploy-policy" {
  name        = var.aws_iam_gh-code-deploy-policy_name
  description = var.aws_iam_gh-code-deploy-policy_description
  policy      = var.aws_iam_gh-code-deploy-policy_content
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
  roles      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-upload-to-s3-policy.arn
}

//attach GH-Code-Deploy policy to `ghaction` user
resource "aws_iam_policy_attachment" "attach2" {
  name       = var.aws_iam_policy_attachment_gh_code_deploy_name
  roles      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-code-deploy-policy.arn
}

//attach gh-ec2-ami policy to `ghaction` user
resource "aws_iam_policy_attachment" "attach3" {
  name       = var.aws_iam_policy_attachment_gh_ec2_ami_name
  roles      = [var.ghaction_user_name]
  policy_arn = aws_iam_policy.gh-ec2-ami-policy.arn
}

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

//CodeDeployServiceRole
resource "aws_iam_role" "code_deploy_service_role" {
  name = var.aws_code_deploy_service_role_name
  assume_role_policy = var.aws_code_deploy_iam_role_assume_role_policy
}

resource "aws_iam_policy_attachment" "attach_code_deploy_service_role" {
    name       = var.aws_iam_policy_attachment_code_deploy_service_name
  roles      = [aws_iam_role.code_deploy_service_role.name]
  policy_arn = var.aws_code_deploy_role
}