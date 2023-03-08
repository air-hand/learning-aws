output "ssh_key_pair" {
  value = aws_key_pair.ec2_keypair.key_name
}

output "ssh_security_group" {
  value = module.public_ssh_security_group.security_group_id
}
