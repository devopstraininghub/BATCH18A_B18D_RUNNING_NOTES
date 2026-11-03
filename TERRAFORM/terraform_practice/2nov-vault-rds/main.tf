
resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 20
  engine               = "mysql"
#  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
#  name                 = "mydatabase"
  username             = data.vault_kv_secret_v2.rds_credentials.data["db_username"]
  password             = data.vault_kv_secret_v2.rds_credentials.data["db_password"]
  skip_final_snapshot  = true
  
}