# 2. DB Subnet Group (Specifies which subnets the database can reside in)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "rds-subnet-group"
}
}


# 3. RDS MySQL Instance Resource
resource "aws_db_instance" "mysql" {
  identifier           = var.db_identifier
  engine               = var.db_engine
  # engine_version       = "8.0.35"
  instance_class       = var.db_instance_class
  allocated_storage    = var.allocated_storage

  
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password # In production, pull from Secrets Manager or pass via TF_VAR_

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.db_security_group_id]
  
  publicly_accessible  = false
  skip_final_snapshot  = true

  tags = {
    Name = var.db_identifier
  }
}


output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}