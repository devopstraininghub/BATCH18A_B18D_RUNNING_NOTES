

provider "aws" {
  region = "us-east-1"
}


provider "vault" {
  address = "http://127.0.0.1:8200"
  token   =  var.vault_token
}


data "vault_kv_secret_v2" "aws_secret" {
    mount = "secret"
    name  = "aws"
}

# Provision the RDS MySQL Database Instance
resource "aws_db_instance" "mysql_db" {
  identifier           = "my-mysql-rds-instance"
  engine               = "mysql"
  instance_class       = "db.t3.micro" # Free Tier eligible
  allocated_storage     = 20            # Minimum for general purpose storage (GB)
  storage_type         = "gp2"
  username             = data.vault_kv_secret_v2.aws_secret.data["db_username"]
  password             = data.vault_kv_secret_v2.aws_secret.data["db_password"]
  

  publicly_accessible    = true # Set to false if you are deploying inside a private subnet
  
  # Required to avoid deletion issues and extra snapshot charges on terraform destroy
  skip_final_snapshot  = true
  deletion_protection  = false

  tags = {
    Environment = "Dev"
    Name        = "MySQL-RDS-Instance"
  }
}