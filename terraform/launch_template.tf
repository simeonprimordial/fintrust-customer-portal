########################################
# Amazon Linux 2023 AMI
########################################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

########################################
# Launch Template
########################################

resource "aws_launch_template" "main" {
  name_prefix = "${local.name_prefix}-lt-"

  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  # User data receives only resource identifiers. Secret values are retrieved
  # at runtime through the instance role and never embedded in the template.
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    aws_region     = var.aws_region
    ecr_repo       = var.ecr_repository_url
    db_host        = aws_db_instance.main.address
    db_name        = var.db_name
    db_secret_arn  = aws_db_instance.main.master_user_secret[0].secret_arn
    app_secret_arn = var.app_secret_arn
  }))

  update_default_version = true

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${local.name_prefix}-ec2"
      }
    )
  }
}
