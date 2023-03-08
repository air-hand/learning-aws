# ex) aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-*" "Name=architecture,Values=x86_64" "Name=virtualization-type,Values=hvm"
# filters -> aws ec2 describe-images help
data "aws_ami" "amazonlinux2" {
  filter {
    name   = "image-id"
    values = ["ami-06ee4e2261a4dc5c3"]
  }

  owners = ["amazon"]
}

data "aws_ami" "amzn2_latest" {
  most_recent = true

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
