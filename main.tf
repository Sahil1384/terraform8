#provider
terraform {
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
#internet gateway attachment 
/*resource "aws_internet_gateway_attachment" "terraform-igw-jass" {
 internet_gateway_id = aws_internet_gateway.terraform-igw.id
  vpc_id              = aws_vpc.terraform.id
}*/


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

resource "aws_route_table" "route498" {
  #The vpc id.
  vpc_id = aws_vpc.terraform.id

  route {
    #The cidr block of the route
    cidr_block = "0.0.0.0/0"
    #identifier of vpc internet gateway 
    gateway_id = aws_internet_gateway.terraform-igw.id

    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

   
  tags = {
    Name = "public"
  }
}

#route table association

resource "aws_route_table_association" "routeroute498" {
  subnet_id      = aws_subnet.terraform23.id
  route_table_id = aws_route_table.route498.id
}


# aws instance 
/*
resource "aws_instance" "terraform32" {
  ami           = "ami-04823729c75214919"  # Replace with your desired AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type
  subnet_id     = aws_subnet.terraform.id
  security_group_ids = aws_security_group.terraform_grp.id
}
*/