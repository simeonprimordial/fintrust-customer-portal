########################################
# EC2 IAM Role
########################################

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

########################################
# Managed Policy Attachments
########################################

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

########################################
# Least-Privilege Secrets Access
########################################

resource "aws_iam_role_policy" "secrets_read" {
  name = "${local.name_prefix}-secrets-read"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadApplicationAndDatabaseSecrets"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_db_instance.main.master_user_secret[0].secret_arn,
          var.app_secret_arn
        ]
      }
    ]
  })
}

########################################
# EC2 Instance Profile
########################################

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.ec2.name
}
