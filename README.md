# Book Review Infrastructure

This repository contains Terraform code to provision AWS infrastructure for a React frontend and Java Spring Boot backend with PostgreSQL.

## Architecture

- **Backend**: EC2 instance (t3.medium) with PostgreSQL installed locally
- **Frontend**: S3 bucket with CloudFront distribution for static file hosting
- **State Management**: S3 bucket for Terraform state storage (no DynamoDB locking)
- **Networking**: VPC with public subnet and internet gateway

## Directory Structure

```
├── modules/
│   ├── backend/          # EC2 + PostgreSQL module
│   ├── frontend/         # S3 + CloudFront module
│   └── shared/           # VPC + S3 state bucket module
├── env/
│   ├── dev/              # Development environment
│   └── prod/             # Production environment
└── README.md
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **EC2 Key Pair** created in AWS (for SSH access)

## Quick Start

### 1. Create EC2 Key Pair

First, create an EC2 key pair in AWS Console or using AWS CLI:

```bash
aws ec2 create-key-pair --key-name bookreview-dev-key --query 'KeyMaterial' --output text > bookreview-dev-key.pem
chmod 400 bookreview-dev-key.pem
```

### 2. Deploy Development Environment

```bash
cd env/dev

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Deploy Production Environment

```bash
cd env/prod

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Configuration

### Environment Variables

You can customize the deployment by creating a `terraform.tfvars` file in each environment directory:

```hcl
# env/dev/terraform.tfvars
aws_region = "us-east-1"
key_name = "your-key-pair-name"
allowed_ips = ["203.0.113.0/24", "198.51.100.0/24"]  # Restrict to specific IPs
db_password = "your-secure-password"
```

### Important Security Notes

1. **Database Password**: Change the default password in production
2. **Allowed IPs**: Restrict `allowed_ips` to specific IP ranges in production
3. **Key Pair**: Use different key pairs for dev and prod environments

## Outputs

After successful deployment, you'll get:

### Backend Information
- EC2 instance public IP
- PostgreSQL connection details (localhost:5432)
- Security group ID

### Frontend Information
- S3 bucket name for static files
- CloudFront distribution domain name

## Spring Boot Configuration

Configure your Spring Boot application to connect to PostgreSQL:

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/bookreviewdb
    username: postgres
    password: admin
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
```

## Frontend Deployment

To deploy your React application:

1. Build your React app: `npm run build`
2. Upload the build files to the S3 bucket:

```bash
aws s3 sync build/ s3://your-frontend-bucket-name --delete
```

3. Invalidate CloudFront cache:

```bash
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
```

## SSH Access

To connect to the backend EC2 instance:

```bash
ssh -i bookreview-dev-key.pem ec2-user@<EC2_PUBLIC_IP>
```

## Cleanup

To destroy the infrastructure:

```bash
cd env/dev  # or env/prod
terraform destroy
```

## Security Best Practices

1. **Network Security**: Restrict allowed IPs to specific ranges
2. **Database Security**: Use strong passwords and consider RDS for production
3. **Access Control**: Use IAM roles and policies for AWS resource access
4. **Monitoring**: Enable CloudTrail and CloudWatch for monitoring
5. **Backup**: Implement regular backups for the database

## Troubleshooting

### Common Issues

1. **S3 Bucket Name Already Exists**: Change the bucket name in variables
2. **Key Pair Not Found**: Ensure the key pair exists in the specified region
3. **Permission Denied**: Check AWS credentials and IAM permissions

### Useful Commands

```bash
# Check Terraform state
terraform show

# List all resources
terraform state list

# Import existing resources (if needed)
terraform import aws_instance.backend i-1234567890abcdef0

# Refresh state
terraform refresh
```

## Contributing

1. Follow the existing module structure
2. Add appropriate tags to all resources
3. Update documentation for any changes
4. Test in dev environment before deploying to prod

## License

This project is licensed under the MIT License.

