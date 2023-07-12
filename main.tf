terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.6.2"
    }
  }
}
 
provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "my_server1" {
  ami           = "ami-04823729c75214919"
  instance_type = "t2.micro"

  tags = {
    Name = "instance3124"
  }
}  

resource "aws_vpc" "sahil8113" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "testing-terraform"
  }
}

resource "aws_security_group" "sahil_sg" {
  name        = "sahil-security-group"
  description = "for testing"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}
