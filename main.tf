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

resource "aws_vpc" "terraform" {
  cidr_block = "10.0.0.0/16"
   tags = {
    Name = "terraform_vpc"
  }
}


# aws subnet creation

resource "aws_subnet" "terraform23" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "terraform_sub"
  }
}

resource "aws_subnet" "terraform24" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "terraform-prvt-subnet"
  }
}

#aws internet-gateway

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "terraform-igw"
  }
}
#aws nat_gateway

resource "aws_nat_gateway" "nat-gw" {
  #the allocation id of elastic ip address for the gateway. 
  allocation_id = aws_eip.elastic_ip.id
  #the subnet id of the subnet in which to place the gateway.
  subnet_id     = aws_subnet.terraform23.id

  tags = {
    Name = "NAT-gw"
  }
}
#aws elastic ip

resource "aws_eip" "elastic_ip" {
  depends_on = [aws_internet_gateway.terraform-igw]
}

#aws security group

resource "aws_security_group" "terraform_grp" {
  name        = "terraform_grp"
  description = "for testing using terraform"
  vpc_id      = aws_vpc.terraform.id

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
    Name = "allow_this"
  }
}

resource "aws_route_table" "public" {
  #The vpc id.
  vpc_id = aws_vpc.terraform.id

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
  vpc_id = aws_vpc.terraform.id

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

#route table association for public

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.terraform23.id
  route_table_id = aws_route_table.public.id
}

#route table association for private 

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.terraform24.id
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

resource "aws_instance" "terraform32" {
  ami           = "ami-04823729c75214919"  # Replace with your desired AMI ID
  instance_type = var.instance-type  # Replace with your desired instance type
  subnet_id     = aws_subnet.terraform24.id
  key_name      = var.key-name
   vpc_security_group_ids = [aws_security_group.terraform_grp.id]  # Use the correct argument name here
   tags = {
    Name = "terrafor32"  # Change this to the desired instance name
  }
}


