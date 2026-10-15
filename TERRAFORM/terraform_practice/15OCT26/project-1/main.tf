

provider "aws" {
  region = "us-east-1"
}

# Create ec2 instance

resource "aws_instance" "prod-server" {
  #ami           = "ami-004d1eaf8eaa0107d"  
  ## ami is immutable 
  ami           = "ami-0b6d9d3d33ba97d99"
# instance_type = "t2.micro"  
# instance_type is mutable and can be changed anytime
  instance_type = "t3.micro"
  count         = 1
  key_name     = "mckey"

  tags = {
    Name = "madhu-server"
  }
}
