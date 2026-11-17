provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { 
    Name = "MAIN-3-TIER-VPC" 
    }
}

# Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)  # count value = 2 
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index].cidr # index starts 0 to count-1 
  availability_zone       = var.public_subnets[count.index].az
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id           = aws_vpc.main.id
  cidr_block       = var.private_subnets[count.index].cidr
  availability_zone = var.private_subnets[count.index].az
  tags             = { Name = "private-subnet-${count.index + 3}" }
}
# resource "aws_subnet" "private" {
#   count             = length(var.private_subnet_cidrs)
#   vpc_id           = aws_vpc.main.id
#   cidr_block       = var.private_subnet_cidrs[count.index]
#   availability_zone = element(var.availability_zones, count.index)


#   tags = {
#     Name = "private-subnet-${count.index + 3}"
#   }
# }




# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  #domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "nat-gateway" }
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-route-table" }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-route-table" }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


