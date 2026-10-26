

provider "aws" {
  
  region = "us-east-1"
}

module "dev_webserver" {
  source = "./ec2-module"
  ami_id = "ami-04b938437b69a2c9c"
  instance_count = 1
  instance_type = "t2.micro"
  tag_server_name = "DevServer"
  key_name = "mckey"
}

module "prod-server" {
  source = "./ec2-module"
  ami_id = "ami-0d97d7f07b25dd693"
  instance_count =  2
  instance_type =  "t3.micro"
  key_name =   "ramanikey"
  tag_server_name = "Prod servers"
}