
module "network_vpc" {
  
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
  value = module.network_vpc.vpc_id
}



# CALLING SECURITY GROUP MODULE TO CREATE SECURITY GROUPS FOR WEB, APP AND DB SERVERS


module "security_groups" {
  source = "./modules/security"

  vpc_id = module.network_vpc.vpc_id
  security_group_name = "main_security_group"

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
  value = module.security_groups.security_group_id
}

# CALLING rds MODULE TO CREATE RDS INSTANCE

module "rds_instance" {
  source = "./modules/rds"

  db_subnet_ids = [module.network_vpc.private_subnet_ids[4], module.network_vpc.private_subnet_ids[5]]
  db_identifier = "app-db-instance"
  db_engine = "mysql"
  db_instance_class = "db.t3.micro"
  allocated_storage = 22
  db_name = "test"
  db_username = "admin"
  db_password = "mypassword"
  db_security_group_id = module.security_groups.security_group_id
}

output "rds_endpoint" {
  value = module.rds_instance.rds_endpoint
}

## alb & tg section 


module "alb" {
  source = "./modules/load_balancer"

  vpc_id = module.network_vpc.vpc_id
  public_subnet_ids = [module.network_vpc.public_subnet_ids[0], module.network_vpc.public_subnet_ids[1]]
  frontend_lb_name = "frontend-alb"
  backend_lb_name = "backend-alb"
  frontend_tg_name = "frontend-tg"
  backend_tg_name = "backend-tg"
  security_group_id = module.security_groups.security_group_id

}

output "alb_frontend_dnsname" {
  value = module.alb.alb_backend_dnsname
}

output "alb_backend_dnsname" {
   value = module.alb.alb_backend_dnsname  
}


### calling launch template module to create launch templates


module "launch_templates" {
  source = "./modules/launch_templates"
  
  frontend_lt_name = "frontend-lt"
  frontend_user_data = "frontend.sh"
  ami_id_frontend = "ami-026ad7eaed3f3e212"
  instance_type = "t3.micro"
  key_name =  "madhukey"
  security_group_id = module.security_groups.security_group_id

  backend_lt_name = "backend-lt"
  ami_id_backend = "ami-0bd217a59a1c761eb"
  backend_user_data = "backend.sh"
}

### calling asg module to create front end & backed asgs

module "autoscaling"{
  source = "./modules/asg" 

  frontend_asg_name = "frontend-asg"
  asg_min_size = 1
  asg_max_size = 1 
  asg_desired_capacity = 1 
  frontend_subnet_ids = [ module.network_vpc.private_subnet_ids[0] , module.network_vpc.private_subnet_ids[1] ]
  frontend_tg_arn = module.alb.frontend_tg_arn
  frontend_lt_id = module.launch_templates.frontend_lt_id

  backend_asg_name = "backend-asg"
  backend_subnet_ids = [ module.network_vpc.private_subnet_ids[2] , module.network_vpc.private_subnet_ids[3] ]
  backend_tg_arn = module.alb.backend_tg_arn
  backend_lt_id = module.launch_templates.backend_lt_id


}

## calling bastion module to create a jump server

module "jumpserver" {

source = "./modules/bastion"
ami_id = "ami-0c230065b91270bc6"
instance_type =  "t3.micro"
key_name =  "madhukey"
public_subnet_id = module.network_vpc.public_subnet_ids[1] 
security_group_id = module.security_groups.security_group_id
bastion_name = "jump/bastion host"

}

###### call route-53 module to host zones 

# module "route53" {

#   source = "./modules/route53"
#   vpc_id = module.network_vpc.vpc_id
#   rds_private_zone_name = "rds.com"
#  rds_record_name = "book.rds.com"
#  rds_endpoint =  module.rds_instance.rds_endpoint
# public_zone_name = "b17facebook.xyz"
# alb_backend_record_name = "api.b18facebook.com"
# alb_backend_dns_name = module.alb.alb_backend_dnsname
# alb_dns_frontend_record = "login.b15facebook.xyz"
# alb_front_dns_name = module.alb.alb_frontend_dnsname


# }

## create certificate using acm module 

# module "acm" {
#  source = "./modules/acm"
#  domain_name =  "b17facebook.xyz"
#  san_names =  "*.b17facebook.xyz "

# }