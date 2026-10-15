
provider "aws" {
  region = "us-east-1"
  alias  = "nv"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "mum"
}

provider "google" {
  ### configure the provider to use the service account key file
}

provider "azurerm" {
  features {}
}


# Create ec2 instance

resource "aws_instance" "prod-server-nv" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"
  count         = 1
  key_name     = "mckey"
  provider     = aws.nv

  tags = {
    Name = "madhu-server-nv"
  }
}

resource "aws_instance" "prod-server-mum" {
  ami           = "ami-0cede6fe40e6ac719"
  instance_type = "t2.micro"
  count         = 1
  key_name     = "mc-mumbaikey"
  provider     = aws.mum

  tags = {
    Name = "madhu-server-mum"
  }
}
