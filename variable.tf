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
  type = list(string)
  default = ["10.0.0.1/24", "10.0.0.2/24"]
}