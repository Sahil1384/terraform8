# aws instance 

resource "aws_instance" "instance" {
  ami           = "ami-04823729c75214919"  # Replace with your desired AMI ID
  instance_type = var.instance-type  # Replace with your desired instance type
  subnet_id     = aws_subnet.public-subnet.id
  key_name      = var.key-name
   associate_public_ip_address = true  # Enable public IP for the instance
  vpc_security_group_ids = [aws_security_group.instance-secgrp.id]  # Use the correct argument name here
   user_data = <<-EOT
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo service httpd start
              sudo chkconfig httpd on
              EOT
   tags = {
    Name = "instance"  # Change this to the desired instance name
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
    Name = "instance-secgrp"
  }
}