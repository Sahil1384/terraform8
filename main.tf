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
    Name = "vpc"
  }
}


# aws subnet creation

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public22-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "public22-subnet"
  }
}


resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block =  "10.0.3.0/24"
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
    aws_subnet.public22-subnet.id,
    aws_subnet.public-subnet.id
    # Add more subnet IDs if you have additional subnets in your VPC
  ]

  tags = {
    Name        = "rds-subnetgrp"
  }
}


#aws RDS creation

resource "aws_db_instance" "sahil-rds" {
 # vpc_id      = aws_vpc.vpc.id
  allocated_storage      = 10
  engine                 = "MariaDB"
  engine_version         = "10.6.14"
  instance_class         = "db.t3.micro"
  identifier             = "mydatabase"
  username               = "sahil"
  password               = "sahil321"
  vpc_security_group_ids = [aws_security_group.rds-securitygrp.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnetgrp.name

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

#application load balancer

resource "aws_lb" "test-loadbalacer" {
  name               = "test-loadbalancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer-sg.id]
  subnets            = [
    aws_subnet.private-subnet.id,
    aws_subnet.public-subnet.id
  ]

  

}

#aws_rds_security_group

resource "aws_security_group" "loadbalancer-sg" {
  name        = "loadbalancer-sg"
  description = "for testing using terraform"
  vpc_id      = aws_vpc.vpc.id


   ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "loadbalancer-sg"
  }
}
# Create an ALB listener
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.test-loadbalacer.arn  # This is the corrected line, referencing the ALB ARN
  port              = 80
  protocol          = "HTTP"

   default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

#target  group for load-balancer

resource "aws_lb_target_group" "target-group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}