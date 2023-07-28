variable "instance-type" {
  
  default = "t2.micro"
}

variable "key-name" {
  
  default = "sahilkey"
}

variable "aws_subnet" {
  
  default = "public-subnet"
}

variable "cidr_block" {
  type = string
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}