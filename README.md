# infrastructure
Repository for AWS Infrastructure

Instructions for setting up infrastructure using Terraform:
- [docs](https://learn.hashicorp.com/collections/terraform/aws-get-started)
- Install Terraform:
  - `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -`
  - `sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`
  - `sudo apt-get update && sudo apt-get install terraform`
- Verify the installation
  - `terraform -help`
- Initialize the directory
  - `terraform init && terraform plan`
- Format and validate the configuration
  - `terraform fmt`
  - `terraform validate`
- Create infrastructure
  - `terraform apply`
- Inspect state
  - `terraform show`
- Destroy Infrastructure
  - `terraform destroy`

Demo commands:
- go to `/VPCs/0x/`
- `export AWS_PROFILE=dev`
- `terraform init && terraform plan`
- `terraform apply`
- `terraform destroy`

Policy:
- CodeDeploy-EC2-S3 - CodeDeployEC2ServiceRole
  - get object from s3 bukcet `codedeploy.prod.bh7cw.me`
- GH-Upload-To-S3 - cicd
  - get/put object from s3 bucket
- GH-Code-Deploy - cicd
- gh-ec2-ami - ghactions