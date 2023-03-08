# ex) aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-kernel-*" "Name=architecture,Values=x86_64" "Name=virtualization-type,Values=hvm" --query 'Images[] | reverse(sort_by(@, &CreationDate))[].Name'
# filters -> aws ec2 describe-images help
data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "creation-date"
    values = ["2023-01-*"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["amazon"]
}

locals {
  domain = "domain.prv"
  hosts = [
    "web.domain.prv",
  ]
}

data "aws_vpc" "tf" {
  id = var.vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.tf.id]
  }

  tags = {
    Terraform = true
    public    = true
  }
}

resource "aws_instance" "bastions" {
  ami                    = data.aws_ami.amazonlinux2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2_keypair.key_name
  vpc_security_group_ids = [module.public_ssh_security_group.security_group_id]

  user_data = templatefile(
    "${path.module}/user_data.tftpl",
    {
      domain = local.domain,
      hosts  = local.hosts
    }
  )

  for_each  = toset(data.aws_subnets.public.ids)
  subnet_id = each.value
  #  metadata_options {
  #    http_tokens = "required"
  #  }
  tags = {
    Name = "Bastion"
  }
}

resource "aws_eip" "bastions" {
  for_each = aws_instance.bastions
  instance = each.value.id
  vpc      = true

  tags = {
    Name = "Bastion"
  }
}
