#provider
terraform {
backend "remote" {
  organization = "Sahil-terraform"
  workspaces {
    name = "terraform8"
  }
}


  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.8.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#aws vpc creation

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
   tags = {
    Name = "terraform_vpc"
  }
}


# aws subnet creation

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-subnet"
  }
}

#aws internet-gateway

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "terraform-igw"
  }
}
#aws nat_gateway

resource "aws_nat_gateway" "nat-gw" {
  #the allocation id of elastic ip address for the gateway. 
  allocation_id = aws_eip.elastic_ip.id
  #the subnet id of the subnet in which to place the gateway.
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NAT-gw"
  }
}
#aws elastic ip

resource "aws_eip" "elastic_ip" {
  depends_on = [aws_internet_gateway.terraform-igw]
}

#aws vpc security group

resource "aws_security_group" "vpc-secgrp" {
  name        = "vpc-secgrp"
  description = "for testing using terraform"
  vpc_id      = aws_vpc.vpc.id

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "vpc-secgrp"
  }
}

resource "aws_route_table" "public" {
  #The vpc id.
  vpc_id = aws_vpc.vpc.id

  route {
    #The cidr block of the route
    cidr_block = "0.0.0.0/0"
    #identifier of vpc internet gateway 
    gateway_id = aws_internet_gateway.terraform-igw.id    
  }

   
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  #The vpc id.
  vpc_id = aws_vpc.vpc.id

  route {
    #The cidr block of the route
    cidr_block = "0.0.0.0/0"
    #identifier of vpc internet gateway 
    nat_gateway_id = aws_nat_gateway.nat-gw.id

    
  }

   
  tags = {
    Name = "private"
  }
}

#route table subnet association for public

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public.id
}

#route table subnet association for private 

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private.id
}

#aws key-pair
/*
resource "aws_key_pair" "terraform-key" {
  key_name   = "terraform-key"  # Change this to your desired key pair name

  tags = {
    Name = "terraform-key"
  }
}
*/

# aws instance 

resource "aws_instance" "instance" {
  ami           = "ami-04823729c75214919"  # Replace with your desired AMI ID
  instance_type = var.instance-type  # Replace with your desired instance type
  subnet_id     = aws_subnet.public-subnet.id
  key_name      = var.key-name
  vpc_security_group_ids = [aws_security_group.instance-secgrp.id]  # Use the correct argument name here
   tags = {
    Name = "terrafor32"  # Change this to the desired instance name
  }
}
#aws instance security group

resource "aws_security_group" "instance-secgrp" {
  name        = "instance-secgrp"
  description = "for testing using terraform"
  vpc_id      = aws_vpc.vpc.id

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "vpc-secgrp"
  }
}

# S3 creation

resource "aws_s3_bucket" "sahil-s3" {
  bucket = "sahil-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
#RDS_subnet group creation

resource "aws_db_subnet_group" "rds-subnetgrp" {
  name             = "rds-subnetgrp"
  description      =  "for testing"
  subnet_ids       = [
    aws_subnet.private-subnet.id,
    #aws_subnet.example_subnet_2.id,
    # Add more subnet IDs if you have additional subnets in your VPC
  ]

  tags = {
    Name        = "rds-subnetgrp"
  }
}


#aws RDS creation

resource "aws_db_instance" "sahil-rds" {
  vpc_id                 = aws_vpc.vpc.id
  allocated_storage      = 10
  engine                 = "MariaDB"
  engine_version         = "10.6.14"
  instance_class         = "db.t3.micro"
  identifier             = "mydatabase"
  username               = "sahil"
  password               = "sahil321"
  vpc_security_group_ids = aws_security_group.rds-securitygrp.id
  aws_db_subnet_group    = "rds-subnetgrp"
  skip_final_snapshot    = true
}

#aws_rds_security_group

resource "aws_security_group" "rds-securitygrp" {
  name        = "rds-securitygrp"
  description = "for testing using terraform"
  vpc_id      = aws_vpc.vpc.id


   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "rds-securitygrp"
  }
}

