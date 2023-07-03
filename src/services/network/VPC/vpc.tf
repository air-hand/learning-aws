# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#tfsec:ignore:aws-ec2-no-public-ip-subnet
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.az_names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  private_subnet_tags = {
    private = true
  }
  public_subnet_tags = {
    public = true
  }

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  #enable_nat_gateway = true

  # private dns host zoneに必要
  enable_dns_hostnames = true
  enable_dns_support   = true
}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
module "public_alb_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name   = "public-alb-security-group"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}
