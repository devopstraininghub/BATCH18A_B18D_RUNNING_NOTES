output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}



# output "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   value       = [
#     aws_subnet.private_subnet_1.id,
#     aws_subnet.private_subnet_2.id,
#     aws_subnet.private_subnet_3.id,
#     aws_subnet.private_subnet_4.id,
#     aws_subnet.private_subnet_5.id,
#     aws_subnet.private_subnet_0.id
#   ]
# }


output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}