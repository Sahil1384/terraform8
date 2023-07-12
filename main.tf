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
    Name = "instance324"
  }
}  

resource "aws_vpc" "sahil81" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "test-terrafrm"
  }
}