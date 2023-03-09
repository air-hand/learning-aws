resource "aws_launch_template" "asg_tmpl" {
  name_prefix   = "sample"
  image_id      = data.aws_ami.amazonlinux2.id
  instance_type = "t2.micro"
  # TODO: applyの度にlatest_versionがインクリメントされるので仕込んだが効果なし https://github.com/hashicorp/terraform-provider-aws/issues/19411
  # https://github.com/hashicorp/terraform-provider-aws/issues/25909
  # metadata_optionsが反映されていない
  update_default_version = false

  metadata_options {
    http_tokens            = "required"
    instance_metadata_tags = "disabled"
  }
}

resource "aws_launch_template" "asg_spot_tmpl" {
  name_prefix            = "sample"
  image_id               = data.aws_ami.amazonlinux2.id
  instance_type          = "t2.micro"
  update_default_version = false

  instance_market_options {
    market_type = "spot"
  }

  metadata_options {
    http_tokens            = "required"
    instance_metadata_tags = "disabled"
  }
}

resource "aws_autoscaling_group" "asg_single_type_sample" {
  name_prefix         = "tf-asg-single-type"
  vpc_zone_identifier = [var.subnet_id]
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3

  launch_template {
    id      = aws_launch_template.asg_spot_tmpl.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "asg_mixed_type_sample" {
  name_prefix         = "tf-asg-mixed-type"
  vpc_zone_identifier = [var.subnet_id]
  desired_capacity    = 2
  min_size            = 2
  max_size            = 3

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.asg_tmpl.id
        version            = "$Latest"
      }
      override {
        instance_type     = "t3.micro"
        weighted_capacity = "2"
      }
    }
  }
}
