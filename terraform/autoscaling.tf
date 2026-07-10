########################################
# Auto Scaling Group
########################################

resource "aws_autoscaling_group" "main" {
  name = "${local.name_prefix}-asg"

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  vpc_zone_identifier = [
    aws_subnet.private_app[0].id,
    aws_subnet.private_app[1].id
  ]

  target_group_arns = [
    aws_lb_target_group.main.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-ec2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}