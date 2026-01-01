variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS Account ID for IAM resources"
  type        = string
}

variable "app_bucket_prefix" {
  description = "S3 bucket prefix for application files (developers access)"
  type        = string
  default     = "startupo-app"
}

variable "data_bucket_prefix" {
  description = "S3 bucket prefix for data/analytics (analysts access)"
  type        = string
  default     = "startupo-data"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "startupo-iam"
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
  default     = "production"
}
