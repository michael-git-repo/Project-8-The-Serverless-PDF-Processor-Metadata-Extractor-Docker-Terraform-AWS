variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for deployment"
}

variable "project_name" {
  type        = string
  default     = "pdf-processor"
  description = "Project name prefix for resources"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment"
}