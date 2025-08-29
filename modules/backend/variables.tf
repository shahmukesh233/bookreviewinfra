variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be launched"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "allowed_ips" {
  description = "List of IP addresses allowed to access the backend"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

