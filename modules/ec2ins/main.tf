data "aws_ami" "ami" {
  most_recent = true

  #filter {
  #  name   = "AMI Name"
  #  values = ["csye6225_*"]
  #}

  owners = ["918834676735"]
}

resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["sg-02d334c66a6c2102f"]
  subnet_id                   = "subnet-0dc0959e2a4ebcd30"
  disable_api_termination     = false
  user_data                   = var.user_data
  
  root_block_device {
    delete_on_termination     = true
    volume_size               = 20
    volume_type               = "gp2"
  } 

  tags = {
    Name = "ubuntu"
  }
}
