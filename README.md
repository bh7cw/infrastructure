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
