resource "aws_launch_configuration" "launch-configuration" {
  name                 = "launch-configuration"
  image_id             = "ami-04823729c75214919"  # Change this to the desired AMI ID
  instance_type        = "t2.micro"              # Change this to your desired instance type
  security_groups      =[aws_security_group.instance-secgrp.id]

  #iam_instance_profile = aws_iam_instance_profile.example.name
}

resource "aws_autoscaling_group" "instance-asg" {
  name                 = "instance-asg"
  launch_configuration = aws_launch_configuration.launch-configuration.id
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  health_check_type    = "EC2"

  vpc_zone_identifier = [aws_subnet.public-subnet.id]  # Change this to the desired subnet ID
tags = {
    Name = "istance-img"  # Change this to the desired instance name
  }
 
}

