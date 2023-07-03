# ex) aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-*" "Name=architecture,Values=x86_64" "Name=virtualization-type,Values=hvm"
# filters -> aws ec2 describe-images help
data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "creation-date"
    values = ["2023-06-*"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-minimal-*-kernel*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
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
