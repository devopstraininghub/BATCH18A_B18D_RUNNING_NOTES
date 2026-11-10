

module "DevServer" {
  source = "./ec2-module/"
  ami_id           = "ami-0d97d7f07b25dd693"
  instance_type    = "t3.micro"
  key_name         = "b18"
  tag_server       = "Dev Server"

}

module "ProdServer" {
  source = "./ec2-module/"
  ami_id           = "ami-0d97d7f07b25dd693"
  instance_type    = "t2.micro"
  key_name         = "madhukey"
  tag_server       = "Prod Server"

}