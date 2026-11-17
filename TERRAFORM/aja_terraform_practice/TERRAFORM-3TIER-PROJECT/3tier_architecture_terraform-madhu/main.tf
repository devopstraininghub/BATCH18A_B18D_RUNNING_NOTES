

module "network" {
  source = "./modules/network"
  vpc_cidr = "170.20.0.0/16"

  public_subnets = [
    { cidr = "170.20.1.0/24", az = "us-east-1a" },
    { cidr = "170.20.2.0/24", az = "us-east-1b" }
  ]

  private_subnets = [
    { cidr = "170.20.3.0/24", az = "us-east-1a" },
    { cidr = "170.20.4.0/24", az = "us-east-1b" },
    { cidr = "170.20.5.0/24", az = "us-east-1a" },
    { cidr = "170.20.6.0/24", az = "us-east-1b" },
    { cidr = "170.20.7.0/24", az = "us-east-1a" },
    { cidr = "170.20.8.0/24", az = "us-east-1b" }
  ]
}

output "vpc_id" {
  value = module.network.vpc_id
}

#############
# secuirty group outputs


module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
  sg_name = "main-security-group"
  ingress_from_port = 0
  ingress_to_port = 0
  ingress_protocol = "-1"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_from_port = 0
  egress_to_port = 0
  egress_protocol = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]
}

output "security_group_id" {
  value = module.security.security_group_id
}

######################### RDS Configuration

module "rds" {
  source = "./modules/rds"
  db_identifier = "app-db"
  db_engine = "mysql"
  db_instance_class = "db.t3.micro"
  db_allocated_storage = 25
  db_name = "test"
  db_username = "admin"
  db_password = "password123" # Consider using environment variables or AWS Secrets Manager instead
  db_security_group_id = module.security.security_group_id
  db_subnet_ids = [
    module.network.private_subnet_ids[4], module.network.private_subnet_ids[5],
  ]
}

output "rds_instance_id" {
  value = module.rds.rds_instance_id
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

