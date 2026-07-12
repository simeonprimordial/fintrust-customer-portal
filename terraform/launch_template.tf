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

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    aws_region  = var.aws_region
    ecr_repo    = "441870953802.dkr.ecr.us-east-1.amazonaws.com/fintrust-customer-portal"
    db_host     = aws_db_instance.main.address
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    secret_key  = "fintrust-secret-key"
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
