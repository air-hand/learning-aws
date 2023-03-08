#tfsec:ignore:aws-ec2-no-public-egress-sgr
#tfsec:ignore:aws-ec2-no-public-ingress-sgr
module "public_ssh_security_group" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"
  name   = "public-ssh-security-group"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}
