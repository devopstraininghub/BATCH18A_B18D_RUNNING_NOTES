

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
  db_password = "Mindcircuit1234" # Consider using environment variables or AWS Secrets Manager instead
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

### ######################### Load Balancer Configuration

module "load_balancers" {
  source = "./modules/load_balancers"
  frontend_alb_name = "frontend-alb"
  backend_alb_name = "backend-alb"
  security_group_id = module.security.security_group_id
  public_subnet_ids = [module.network.public_subnet_ids[0], module.network.public_subnet_ids[1]]
  frontend_tg_name = "frontend-tg"
  backend_tg_name = "backend-tg"
  vpc_id = module.network.vpc_id
}

#### launch templates configuration

module "launch_templates" {
  source = "./modules/launch_templates"
  frontend_lt_name = "frontend-lt"
  backend_lt_name = "backend-lt"
  key_name = "madhukey"
  ami_id_frontend = "ami-0b6fc738e4f1c16b9"
  ami_id_backend = "ami-0f1a7a7ba9b3b39d1"
  instance_type = "t3.micro"
  frontend_user_data = "frontend.sh"
  backend_user_data = "backend.sh"
  security_group_id = module.security.security_group_id
}


## auto scaling group configuration

module "autoscaling_groups" {
  source = "./modules/asg"
  frontend_asg_name = "frontend-asg"
  backend_asg_name = "backend-asg"
  asg_min_size = 1
  asg_max_size = 1
  asg_desired_capacity = 1
  frontend_subnet_ids = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  backend_subnet_ids = [module.network.private_subnet_ids[2], module.network.private_subnet_ids[3]]
  frontend_tg_arn = module.load_balancers.frontend_tg_arn
  backend_tg_arn = module.load_balancers.backend_tg_arn
  frontend_lt_id = module.launch_templates.frontend_lt_id
  backend_lt_id = module.launch_templates.backend_lt_id
}


## Bastion Host Configuration 

module "bastion" {
  source = "./modules/bastion"
  ami_id = "ami-0add9dc62cfab3c11"
  instance_type = "t3.micro"
  key_name = "madhukey"
  public_subnet_id = module.network.public_subnet_ids[0]
  security_group_id = module.security.security_group_id
  bastion_name = "bastion-host"
}


output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

# route 53 configuration
# module "route53" {
#   source = "./modules/route53"
#   domain_name = "example.com"
#   vpc_id = module.network.vpc_id
#   public_subnet_ids = [module.network.public_subnet_ids[0], module.network.public_subnet_ids[1]]
# }

# module "acm" {
#   source = "./modules/acm"
#   domain_name = "example.com"
#   san_names   = ["www.example.com", "api.example.com"]
# }