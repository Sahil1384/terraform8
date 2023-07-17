#aws vpc creation

resource "aws_vpc" "terraform" {
  cidr_block = "10.0.0.0/16"
}