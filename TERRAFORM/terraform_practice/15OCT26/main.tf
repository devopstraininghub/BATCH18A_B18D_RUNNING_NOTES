
provider "aws" {
  region = "us-east-1"
  alias  = "nv"

}

provider "aws" {
  alias  = "mum"
  region = "us-west-2"
}

resource "aws_instance" "server_nv" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  provider      = aws.nv

  tags = {
    Name = "ExampleInstance"
  }
}

resource "aws_instance" "server_mum" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  provider      = aws.mum

  tags = {
    Name = "ExampleInstance"
  }
}