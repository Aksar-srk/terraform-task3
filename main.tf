# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

# Create a security group to allow SSH and HTTP traffic
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web and SSH inbound traffic"
  vpc_id      = "vpc-003506f72559404e4" # <<-- REPLACE with your VPC ID

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}

# Create an EC2 instance
resource "aws_instance" "docker_host" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = "devops" # <<-- REPLACE with your key pair name
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id     = "subnet-064a38f726cb62cae"

  associate_public_ip_address = true


  # User data script to install Docker and run a container
  user_data = <<-EOT
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 --name my-nginx-container nginx:latest
              EOT

  tags = {
    Name = "Docker-Host"
  }
}
