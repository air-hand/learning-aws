#tfsec:ignore:aws-ec2-enable-at-rest-encryption
#tfsec:ignore:aws-ec2-enforce-http-token-imds
resource "aws_spot_instance_request" "web" {
  ami           = data.aws_ami.amazonlinux2.id
  instance_type = "t3.micro"
  user_data     = file("${path.module}/user_data.sh")
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_pair_name

  metadata_options {
    http_tokens = "required"
  }

  wait_for_fulfillment = true
}

locals {
  spot_instance_tags = {
    Name = "Web"
  }
}

resource "aws_ec2_tag" "for_spot_instance" {
  resource_id = aws_spot_instance_request.web.spot_instance_id
  for_each    = local.spot_instance_tags
  key         = each.key
  value       = each.value
}
