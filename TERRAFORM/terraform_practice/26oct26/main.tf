

provider "aws" {
  region = "us-east-1"
}


module "madhu-ec2creation" {

 source = "./ec2-module"
 ami_id = "ami-0d97d7f07b25dd693"
 key_name = "mckey"
 instance_type = "t2.micro"
 tag_server_name = "Madhu-server"
 
}