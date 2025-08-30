# Backend outputs
output "backend_instance_id" {
  description = "ID of the backend EC2 instance"
  value       = module.backend.instance_id
}

output "backend_public_ip" {
  description = "Public IP address of the backend EC2 instance"
  value       = module.backend.public_ip
}

output "backend_private_ip" {
  description = "Private IP address of the backend EC2 instance"
  value       = module.backend.private_ip
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string for localhost connection"
  value       = module.backend.postgresql_connection_string
  sensitive   = true
}

output "postgresql_host" {
  description = "PostgreSQL host (localhost for Spring Boot app)"
  value       = module.backend.postgresql_host
}

output "postgresql_port" {
  description = "PostgreSQL port"
  value       = module.backend.postgresql_port
}

output "postgresql_database" {
  description = "PostgreSQL database name"
  value       = module.backend.postgresql_database
}

output "postgresql_username" {
  description = "PostgreSQL username"
  value       = module.backend.postgresql_username
}

# Frontend outputs
output "frontend_s3_bucket_name" {
  description = "Name of the S3 bucket for frontend static files"
  value       = module.frontend.s3_bucket_name
}

output "frontend_cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.frontend.cloudfront_distribution_domain_name
}

output "frontend_cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.frontend.cloudfront_distribution_id
}

# Shared infrastructure outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.shared.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.shared.public_subnet_id
}

output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.shared.state_bucket_name
}


