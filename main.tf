#pro
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.8.0"
    }
  }
}

#aws vpc creation

resource "aws_vpc" "terraform" {
  cidr_block = "10.0.0.0/16"
}

# aws subnet creation

resource "aws_subnet" "terraform" {
  vpc_id     = aws_vpc.terraform.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "terraform_sub"
  }
}

#aws internet-gateway

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "terraform-igw"
  }
}
#internet gateway attachment

resource "aws_internet_gateway_attachment" "terraform-igw" {
  internet_gateway_id = aws_internet_gateway.terraform-igw.id
  vpc_id              = aws_vpc.terraform.id
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

# aws instance 
/*
resource "aws_instance" "terraform32" {
  ami           = "ami-04823729c75214919"  # Replace with your desired AMI ID
  instance_type = "t2.micro"  # Replace with your desired instance type
  subnet_id     = aws_subnet.terraform.id
  security_group_ids = aws_security_group.terraform_grp.id
}
*/