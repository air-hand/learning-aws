module "kms" {
  source = "./services/security/KMS"
}

module "vpc_local" {
  source = "./services/network/VPC"

  region = var.region

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  az_names = var.az_names

  vpc_private_subnets = var.vpc_private_subnets
  vpc_public_subnets  = var.vpc_public_subnets
}

module "iam" {
  source = "./services/security/IAM"
}

module "bastions" {
  source = "./services/network/Bastion"

  vpc_id = module.vpc_local.vpc_id
}

module "ec2_sample" {
  source = "./services/compute/EC2"

  vpc_id                 = module.vpc_local.vpc_id
  subnet_id              = module.vpc_local.public_subnets[0]
  vpc_security_group_ids = [module.vpc_local.http_security_group, module.bastions.ssh_security_group]
  key_pair_name          = module.bastions.ssh_key_pair
}

module "rds_sample" {
  source  = "./services/database/RDS"
  vpc_id  = module.vpc_local.vpc_id
  az_name = var.az_names[0]
}

module "efs" {
  source  = "./services/storage/EFS"
  az_name = reverse(var.az_names)[0]
}

module "ecs" {
  source = "./services/container/ECS"
}
