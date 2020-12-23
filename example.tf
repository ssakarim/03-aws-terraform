terraform {
  backend "remote" {
    organization = "snefro"
    workspaces {
      name = "03-aws-terraform"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

data "aws_security_group" dflt_sg {
  name = "default"
}

resource "aws_security_group" "ec2_ssh" {
  name = "ec2_ssh_sg"
  ingress {
    from_port = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
 # ami             = "ami-08d70e59c07c61a3a" #ubuntu/us-west-2
  ami             = "ami-0e472933a1395e172" #Amazon Linux 2/us-west-2
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_ssh.id,data.aws_security_group.dflt_sg.id]
  key_name        = aws_key_pair.ec2_ssh_key.key_name
  user_data = <<-EOF
              #!/bin/bash
              yum -y update
              yum -y install httpd.x86_64
              systemctl start httpd.service
              systemctl enable https.service
              echo "Hello World from $(hostname -f)" >> /var/www/html/index.html
              EOF
}

resource "aws_key_pair" "ec2_ssh_key" {
  #the used command in cygwin is -> ssh-keygen -y -f EC2tutorial.pem
  key_name   = "my_EC2_tutorial_public_key"
  public_key = var.pub_key
}

output "ip" {
  value = aws_instance.example.public_dns
}