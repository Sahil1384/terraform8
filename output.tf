output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "aws_subnet" {
  value = aws_subnet.public-subnet.id
}

