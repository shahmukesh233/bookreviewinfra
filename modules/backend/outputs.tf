output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.backend.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.backend_eip.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.backend.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.backend_sg.id
}

output "postgresql_connection_string" {
  description = "PostgreSQL connection string for localhost connection"
  value       = "postgresql://${var.db_user}:${var.db_password}@localhost:5432/${var.db_name}"
  sensitive   = true
}

output "postgresql_host" {
  description = "PostgreSQL host (localhost for Spring Boot app)"
  value       = "localhost"
}

output "postgresql_port" {
  description = "PostgreSQL port"
  value       = 5432
}

output "postgresql_database" {
  description = "PostgreSQL database name"
  value       = var.db_name
}

output "postgresql_username" {
  description = "PostgreSQL username"
  value       = var.db_user
}

