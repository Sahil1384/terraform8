#RDS_subnet group creation

resource "aws_db_subnet_group" "rds-subnetgrp" {
  name             = "rds-subnetgrp"
  description      =  "for testing"
  subnet_ids       = [
    aws_subnet.private-subnet.id,
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