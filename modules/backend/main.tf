# Backend Module - EC2 with PostgreSQL
# This module creates an EC2 instance with PostgreSQL installed

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "backend_sg" {
  name_prefix = "${var.name_prefix}-backend-sg"
  description = "Security group for backend EC2 instance"
  vpc_id      = var.vpc_id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # PostgreSQL (only from allowed IPs)
  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # SSH (for management)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-backend-sg"
  })
}

# EC2 Instance
resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  subnet_id              = var.subnet_id

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  }))

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-backend"
  })

  depends_on = [aws_security_group.backend_sg]
}

# EIP for the backend instance
resource "aws_eip" "backend_eip" {
  instance = aws_instance.backend.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-backend-eip"
  })
}

