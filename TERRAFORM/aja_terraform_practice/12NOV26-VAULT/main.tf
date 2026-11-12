

data "vault_kv_secret_v2" "rds_credentials" {
  mount = "secret"
  name  = "aws"

}

resource "aws_db_instance" "mysql" {
  identifier = "aja-sql-rds"
  # Database configuration
  engine         = "mysql"
  #engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage     = 20
  storage_type          = "gp3"

  # Database credentials
  db_name  = "myappdb"
  username = data.vault_kv_secret_v2.rds_credentials.data["db_username"]
  password = data.vault_kv_secret_v2.rds_credentials.data["db_password"]

  # Connectivity
  port                = 3306

  # Backup configuratio

  # Availability
  multi_az = false

  # Deletion protection
  ##deletion_protection = true
  skip_final_snapshot = true

  tags = {
    Name        = "my-mysql-db"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}