output "rds_endpoint" {
  description = "RDS endpoint used by the application instances"
  value       = aws_db_instance.main.endpoint
}

output "db_username" {
  description = "RDS master username"
  value       = aws_db_instance.main.username
}

output "db_master_secret_arn" {
  description = "ARN of the RDS-managed master credential in AWS Secrets Manager"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
