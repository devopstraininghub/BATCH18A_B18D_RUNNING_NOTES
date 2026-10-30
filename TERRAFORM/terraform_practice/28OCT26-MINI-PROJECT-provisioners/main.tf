# Create a VPC — 10.81.0.0/16
# Create an Internet Gateway
# Create a Custom Route Table
# Create a public Subnet — 10.81.3.0/24
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


# Create a Custom public Route Table

resource "aws_route_table" "prod-rt"  {
    
    vpc_id = aws_vpc.prod-vpc.id
   
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prod-igw.id

        }

    tags = {
        Name = "prod-rt"
    }

}

# Create a public Subnet — 10.81.3.0/24

resource "aws_subnet" "prod-subnet" {

   vpc_id = aws_vpc.prod-vpc.id
   cidr_block = "10.81.3.0/24"
   availability_zone = "us-east-1a"
   tags = {
       Name = "prod-subnet"
   }  
}

 #Associate the subnet with the route table

resource "aws_route_table_association" "prod-rta" {
    subnet_id = aws_subnet.prod-subnet.id
    route_table_id = aws_route_table.prod-rt.id
}

# Create a Security Group allowing ports 22, 80, 443 (or all ports/traffic, for this exercise) 

resource "aws_security_group" "prod-sg" {
    name = "prod-sg"
    description = "Allow all port 22 80 443 traffic"
    vpc_id = aws_vpc.prod-vpc.id

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

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "prod-sg"
    }
}

# Create a Network Interface with an IP in the subnet (10.81.3.0/24) from step 4

resource "aws_network_interface" "prod-eni" {
    subnet_id = aws_subnet.prod-subnet.id
    private_ips = ["10.81.3.33"]
    security_groups = [aws_security_group.prod-sg.id]

    tags = {
        Name = "prod-eni"
    }

} 

# Assign an Elastic IP to the network interface from step 7

resource "aws_eip" "prod-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.prod-eni.id
  associate_with_private_ip = "10.81.3.33"
  depends_on                = [aws_internet_gateway.prod-igw] # EIP needs the IGW attached first

  tags = {
    Name = "prod-eip"
  }
}

resource "time_sleep" "wait_60sec" {
  depends_on = [ aws_eip.prod-eip ]

  create_duration = "30s"
}

# Create an EC2 instance using it — and launch an application on it

resource "aws_instance" "prod-fb-srv" {
  ami           = "ami-0ed59cbb87dfa8dba" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name      = "madhukey" # Replace with your key pair name

  network_interface {
    network_interface_id = aws_network_interface.prod-eni.id
    device_index         = 0
  }

  # user_data = file("facebook.sh") # This file should contain the commands to launch your application
    
#ssh -i "keypair" ec2-user@publicIP
    
   connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/Madhukiran/Desktop/batch18keys/madhukey.pem")
    host        = aws_eip.prod-eip.public_ip
  }
     
    provisioner "file" {
      source = "index.html"
      destination = "/tmp/index.html"
    } 

    provisioner "remote-exec" {
        inline = [
        "sudo yum update -y",
        "sudo yum install -y httpd",
        "sudo systemctl start httpd",
        "sudo systemctl enable httpd",
        "sudo mv /tmp/index.html /var/www/html/index.html "
        ]
    }



    provisioner "local-exec" {
    command = "echo 'THIS IS A TEST FILE TO TEST LOCAL EXEC PROVISIONER' >> localfile.txt"
    }


  tags = {
    Name = "prod-facebook-srv"
  }
}




output "instance_public_ip" {
  value = aws_eip.prod-eip.public_ip
}