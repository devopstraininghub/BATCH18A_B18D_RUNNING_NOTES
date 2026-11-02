# Create a VPC — 10.81.0.0/16
# Create an Internet Gateway
# Create a Custom Route Table
# Create a public Subnet — 10.81.3.0/24  (251/ 256 IPs)
# Associate the subnet with the route table
# Create a Security Group allowing ports 22, 80, 443 (or all ports/traffic, for this exercise)
# Create a Network Interface with an IP in the subnet from step 4
# Assign an Elastic IP to the network interface from step 7
# Create an EC2 instance using it — and launch an application on it

provider "aws" {
  region = "us-east-1"
}


# Create a VPC — 10.81.0.0/16

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.81.0.0/16"

  tags = {
    Name = "prod-vpc"
  }
  }

# Create an Internet Gateway


resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}

#rCreate a Custom Route Table 

resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod-vpc.id

  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "prod-rt"
  }

}


resource "aws_subnet" "prod-subnet" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.81.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}


resource "aws_route_table_association" "prod-rt-assoc" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-rt.id


}

# Create a Security Group allowing ports 22, 80, 443 (or all ports/traffic, for this exercise)

resource "aws_security_group" "prod-sg" {
  name        = "prod-sg"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}


## Create a Network Interface with an IP in the subnet from step 4  

resource "aws_network_interface" "prod-eni" {
  subnet_id       = aws_subnet.prod-subnet.id
  private_ips     = ["10.81.3.33"]
  security_groups = [aws_security_group.prod-sg.id]

    tags = {
        Name = "prod-eni"
    }

}

## Assign an Elastic IP to the network interface from step 7

resource "aws_eip" "prod-eip" {
  domain = "vpc"
  network_interface = aws_network_interface.prod-eni.id
  associate_with_private_ip = "10.81.3.33"

  tags = {
    Name = "prod-eip"
  }
}

# Create an EC2 instance using it — and launch an application on it

resource "aws_instance" "prod-server" {
  ami           = "ami-0c230065b91270bc6" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.micro"
  key_name      = "madhukey" # Replace with your key pair name
  

  network_interface {
    network_interface_id = aws_network_interface.prod-eni.id
    device_index         = 0
  }

  user_data = file("facebook.sh") # Path to your user data script

  tags = {
    Name = "prod-server"
  }
  
}