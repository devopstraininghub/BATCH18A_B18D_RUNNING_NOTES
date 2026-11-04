
module "network" {
  source = "./modules/network"

  vpc_cidr =  "170.20.0.0/16"
  
   public_subnets = [  
    { cidr = "170.20.1.0/24", az = "us-east-1a" },
    { cidr = "170.20.2.0/24", az = "us-east-1b" }
   ]

   private_subnets =  [
    { cidr = "170.20.3.0/24", az = "us-east-1a" },
    { cidr = "170.20.4.0/24", az = "us-east-1b" },
    { cidr = "170.20.5.0/24", az = "us-east-1a" },
    { cidr = "170.20.6.0/24", az = "us-east-1b" },
    { cidr = "170.20.7.0/24", az = "us-east-1a" },
    { cidr = "170.20.8.0/24", az = "us-east-1b" }
  ]



#  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b", "us-east-1a", "us-east-1b"]  # ✅ Added this line

 
#  private_subnet_cidrs = [
#     "170.20.3.0/24",
#     "170.20.4.0/24",
#     "170.20.5.0/24",
#     "170.20.6.0/24",
#     "170.20.7.0/24",
#     "170.20.8.0/24"
#   ]
}

output "vpc_output_from_nwmodule" {
  
  value = module.network.vpc_id
}

# # Module: Security Groups
module "security_group" {
  source              = "./modules/security"
  vpc_id             = module.network.vpc_id
  sg_name            = "MAIN-security-group"
  ingress_from_port  = 0
  ingress_to_port    = 0
  ingress_protocol   = "-1"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_from_port   = 0
  egress_to_port     = 0
  egress_protocol    = "-1"
  egress_cidr_blocks = ["0.0.0.0/0"]
}

output "security_group_id" {
value = module.security_group.security_group_id
}



module "rds" {
  source               = "./modules/rds"
  db_identifier        = "app-db"
  db_engine           = "mysql"
  db_instance_class   = "db.t3.micro"
  db_allocated_storage = 25
  db_name             = "test"
  db_username         = "admin"
  db_password         = "password123"  # Consider using AWS Secrets Manager or Vault  
  db_security_group_id = module.security_group.security_group_id
  db_subnet_ids       = [module.network.private_subnet_ids[4], module.network.private_subnet_ids[5]]  # ✅ Fixed Reference
}

output "rds_name" {
  
  value = module.rds.rds_endpoint
}


# # Module: Load Balancers
module "alb" {
  source            = "./modules/load_balancers"
  frontend_alb_name = "frontend-alb"
  backend_alb_name  = "backend-alb"
  security_group_id = module.security_group.security_group_id
  public_subnet_ids = [module.network.public_subnet_ids[1], module.network.public_subnet_ids[0]]
  frontend_tg_name  = "frontend-tg"
  backend_tg_name   = "backend-tg"
  vpc_id            = module.network.vpc_id
}

# output "alb_front_dns_name" {
#   value = module.load_balancers.aws_lb.frontend_alb.arn
# }

# output "alb_backend_dns_name" {
#   value = module.load_balancers.aws_lb.backend_alb.arn
# }

module "launch_templates" {
  source              = "./modules/launch_templates"
  frontend_lt_name    = "frontend-lt"
  backend_lt_name     = "backend-lt"
  key_name            = "madhu"
  ami_id_frontend     = "ami-026ff2aed0f235b98"
  ami_id_backend      = "ami-0cf6e84dc7d56f9d1"
  instance_type       = "t3.micro"
  frontend_user_data  = "frontend.sh"
  backend_user_data   = "backend.sh"
  security_group_id   = module.security_group.security_group_id
}



module "autoscaling" {
  source               = "./modules/asg"
  frontend_asg_name    = "frontend-asg"
  backend_asg_name     = "backend-asg"
  asg_min_size         = 1
  asg_max_size         = 1
  asg_desired_capacity = 1
  frontend_subnet_ids  = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  backend_subnet_ids   = [module.network.private_subnet_ids[2], module.network.private_subnet_ids[3]]
  frontend_tg_arn      = module.alb.frontend_tg_arn
  backend_tg_arn       = module.alb.backend_tg_arn
  frontend_lt_id        =  module.launch_templates.frontend_lt_id
  backend_lt_id = module.launch_templates.backend_lt_id

}

module "bastion" {
  source            = "./modules/bastion"
  ami_id            = "ami-0c3389a4fa5bddaad"
  instance_type     = "t3.micro"
  key_name          = "madhu"
  public_subnet_id  = module.network.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id
}

output "jump_server" {
  value = module.bastion.bastion_public_ip
}

module "route53" {
  source              = "./modules/route53"
  vpc_id              = module.network.vpc_id
  rds_endpoint        = module.rds.rds_endpoint
  alb_dns_name        = module.alb.alb_backend_dns
  alb_front_dns_name = module.alb.alb_frontend_dns
}


module "acm" {
  source      = "./modules/acm"
  domain_name = "b17facebook.xyz"
  san_names   = ["*.b17facebook.xyz"]
}
