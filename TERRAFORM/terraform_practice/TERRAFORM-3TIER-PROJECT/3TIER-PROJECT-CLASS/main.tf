
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