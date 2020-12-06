# infrastructure
Repository for AWS Infrastructure

Credential:
- no secrets set up in secrets
- export AWS_PROFILE in local machine to use the credential

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
- build vpc:
  - go to `/VPCs/0x/`
  - `export AWS_PROFILE=prod` //for dev: `export AWS_PROFILE=dev`
  - `terraform init && terraform plan`
  - `terraform apply`
  - `terraform destroy`
- build all resources:
  - `cd modules/services`
  - `export AWS_PROFILE=prod`
  - `alias t=terraform`
  - `t init && t plan -var 'env=prod'`
  - `t apply -var 'env=prod'`//for dev: `t apply -var 'env=dev'`

Policy:
- CodeDeploy-EC2-S3 - CodeDeployEC2ServiceRole
  - get object from s3 bukcet `codedeploy.prod.bh7cw.me`
- GH-Upload-To-S3 - cicd
  - get/put object from s3 bucket
- GH-Code-Deploy - cicd
- gh-ec2-ami - ghactions

SSL:
1. prepare ssl: get private key and CSR
- [namecheap](https://www.namecheap.com/support/knowledgebase/article.aspx/9592/14/generating-a-csr-on-amazon-web-services-aws/)
- commands:
```
sudo openssl genrsa -out private.key 2048 # generate the private key
sudo openssl req -new -key private.key -out csr.pem # generate CSR based on the Private Key
```
2. activate on namecheap
3. set up CNAME in DNS, in my case: it's in aws route53
4. install ssl: import in aws certificate manager
- [namecheap](https://www.namecheap.com/support/knowledgebase/article.aspx/9593/33/installing-an-ssl-certificate-on-amazon-web-services-aws/)
5. Set up in load balancer: two options
- Load Balancers menu >> Listeners >> View/edit certificates
- Command:
```
aws elb set-load-balancer-listener-ssl-certificate --load-balancer-name my-loadbalancer --load-balancer-port 443 --ssl-certificate-id arn:aws:iam::123456789012:server-certificate/certificate_object_name
```
Parameter my-loadbalancer is the name of your load balancer.