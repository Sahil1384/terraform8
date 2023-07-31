variable "instance-type" {
  
  default = "t2.micro"
}

variable "key-name" {
  
  default = "sahilkey"
}

variable "aws_subnet" {
  
  default = "public-subnet"
}

variable "aws_security_group" {
  type    ="string"
  default = "instance-secgrp"
}
