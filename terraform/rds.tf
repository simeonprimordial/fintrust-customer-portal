########################################
# DB Subnet Group
########################################

resource "aws_db_subnet_group" "main" {
  name = "${local.name_prefix}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db[0].id,
    aws_subnet.private_db[1].id
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-db-subnet-group"
    }
  )
}

########################################
# Amazon RDS MySQL Instance
########################################

resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username

  # RDS generates, stores, and rotates the master password in Secrets Manager.
  # No database password is accepted as a Terraform input or stored in source code.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  apply_immediately = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-mysql"
    }
  )
}
