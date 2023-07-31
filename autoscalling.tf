resource "aws_launch_configuration" "launch-configuration" {
  name                 = "launch-configuration"
  image_id             = "ami-04823729c75214919"  # Change this to the desired AMI ID
  instance_type        = "t2.micro"              # Change this to your desired instance type
  security_groups      = var.aws_security_group 

  #iam_instance_profile = aws_iam_instance_profile.example.name
}

