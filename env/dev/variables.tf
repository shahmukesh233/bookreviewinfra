variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "bookreview-dev"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "bookreview-terraform-state-dev"
}

variable "availability_zone" {
  description = "Availability zone for resources"
  type        = string
  default     = "us-east-1a"
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "bookreview-dev-key"
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the backend"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: In production, restrict this to specific IPs
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "bookreviewdb"
}

variable "db_user" {
  description = "PostgreSQL database user"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend static files"
  type        = string
  default     = "bookreview-frontend-dev"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "bookreview-team"
    Project     = "bookreview"
  }
}


