output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "http_security_group" {
  value = module.public_alb_security_group.security_group_id
}

#output "ssh_security_group" {
#  value = module.public_ssh_security_group.security_group_id
#}
#
#output "ssh_key_pair" {
#  value = aws_key_pair.ec2_keypair.key_name
#}
