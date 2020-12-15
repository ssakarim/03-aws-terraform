terraform {
  backend "remote" {
    organization = "snefro"
    workspaces {
      name = "certificate_preparation"
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

resource "aws_security_group" "ec2_ssh" {
  name = "ec2_ssh_sg"
  ingress {
    from_port = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami             = "ami-08d70e59c07c61a3a"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2_ssh.id]
  key_name        = aws_key_pair.ec2_ssh_key.key_name
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example.id
}

resource "aws_key_pair" "ec2_ssh_key" {
  key_name   = "my_EC2_tutorial_public_key"
  #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmgiQFS7XZ63Ben6MvKlDlR8LJ5HsRQQQKXFMnEu+vmnVKEIc5PrstlcjM5w6nc1QIyJPbtCVWaKqbdxwwKAm+pXw8UeDwViJnCyr0nqWRG9xWTGgV3Zdmp9NfOCIeqmXmzr9CrGDr8weKGJGPhHLdIXekIvLPT2/S50BIcIk5WTVI49e9gXXbtdnpB2++b8J9+9o7MSBdxE6zniNY0ZO85P6Q1ux/Oeeflk9VfKPRc43A1V6I1PuegomXdqUG8EDWjEcpXlkVOoRz67V7pANdDHnf6LjxphAVyxhNis4uK+j5NjHbzFcOJHbLwOnmyurTIpGuXkLCygij8cJWycv7"
  public_key = var.pub_key
}

output "ip" {
  value = aws_eip.ip.public_ip
}