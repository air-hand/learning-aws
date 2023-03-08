locals {
  dns = {
    "web" = aws_spot_instance_request.web.private_ip
  }
}

resource "aws_route53_zone" "private" {
  name = "domain.prv"
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "private" {
  zone_id  = aws_route53_zone.private.zone_id
  for_each = local.dns
  name     = each.key
  type     = "A"
  ttl      = "300"
  records  = [each.value]
}
