variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "fintrust-customer-portal"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

########################################
# Database Variables
########################################

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "fintrust"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "admin"
}