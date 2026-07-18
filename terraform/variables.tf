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

########################################
# Application Deployment Variables
########################################

variable "ecr_repository_url" {
  description = "Full Amazon ECR repository URL containing the application image"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}\\.dkr\\.ecr\\.[a-z0-9-]+\\.amazonaws\\.com/.+$", var.ecr_repository_url))
    error_message = "ecr_repository_url must be a valid private Amazon ECR repository URL."
  }
}

variable "app_secret_arn" {
  description = "ARN of an existing AWS Secrets Manager secret containing the Flask SECRET_KEY as a plaintext secret value"
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:.+$", var.app_secret_arn))
    error_message = "app_secret_arn must be a valid AWS Secrets Manager secret ARN."
  }
}

########################################
# EC2 Variables
########################################

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Optional EC2 Key Pair"
  type        = string
  default     = ""
}

########################################
# Auto Scaling Variables
########################################

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
}
