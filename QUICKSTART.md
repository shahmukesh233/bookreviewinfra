# Quick Start Guide

This guide will help you deploy the Book Review infrastructure in under 10 minutes.

## Prerequisites

1. **AWS CLI** installed and configured
2. **Terraform** >= 1.0 installed
3. **PowerShell** (for Windows) or **Bash** (for Linux/Mac)

## Step 1: Create EC2 Key Pair

Create an EC2 key pair for SSH access:

```powershell
# Windows (PowerShell)
aws ec2 create-key-pair --key-name bookreview-dev-key --query 'KeyMaterial' --output text > bookreview-dev-key.pem

# Linux/Mac (Bash)
aws ec2 create-key-pair --key-name bookreview-dev-key --query 'KeyMaterial' --output text > bookreview-dev-key.pem
chmod 400 bookreview-dev-key.pem
```

## Step 2: Configure Environment

1. Copy the example configuration:
   ```powershell
   # Windows
   Copy-Item "env\dev\terraform.tfvars.example" "env\dev\terraform.tfvars"
   
   # Linux/Mac
   cp env/dev/terraform.tfvars.example env/dev/terraform.tfvars
   ```

2. Edit `env/dev/terraform.tfvars` and update:
   - `key_name` to match your key pair name
   - `allowed_ips` to your IP address (optional for dev)

## Step 3: Deploy Infrastructure

### Using PowerShell (Windows):
```powershell
.\scripts\deploy.ps1 dev plan
.\scripts\deploy.ps1 dev apply
```

### Using Bash (Linux/Mac):
```bash
./scripts/deploy.sh dev plan
./scripts/deploy.sh dev apply
```

## Step 4: Deploy Frontend (Optional)

If you have a React application:

1. Build your React app:
   ```bash
   npm run build
   ```

2. Deploy to S3:
   ```powershell
   # Windows
   .\scripts\deploy-frontend.ps1 dev
   
   # Linux/Mac
   ./scripts/deploy-frontend.sh dev
   ```

## Step 5: Access Your Application

After deployment, you'll see outputs like:

```
backend_public_ip = "54.123.45.67"
frontend_cloudfront_domain_name = "d1234567890abc.cloudfront.net"
```

- **Backend**: SSH to the EC2 instance using the public IP
- **Frontend**: Access via the CloudFront domain name

## Step 6: Configure Spring Boot

Update your Spring Boot `application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/bookreviewdb
    username: postgres
    password: admin
    driver-class-name: org.postgresql.Driver
```

## Cleanup

To destroy the infrastructure:

```powershell
# Windows
.\scripts\deploy.ps1 dev destroy

# Linux/Mac
./scripts/deploy.sh dev destroy
```

## Troubleshooting

### Common Issues:

1. **"Key pair not found"**: Ensure the key pair exists in the correct region
2. **"Bucket name already exists"**: Change the bucket name in `terraform.tfvars`
3. **"Permission denied"**: Check AWS credentials and IAM permissions

### Useful Commands:

```bash
# Check Terraform state
terraform show

# List resources
terraform state list

# Refresh state
terraform refresh
```

## Next Steps

1. **Security**: Restrict `allowed_ips` to specific IP ranges
2. **Monitoring**: Set up CloudWatch alarms
3. **Backup**: Implement database backups
4. **CI/CD**: Integrate with your deployment pipeline

## Support

For issues or questions:
1. Check the main README.md for detailed documentation
2. Review the Terraform outputs for connection details
3. Check AWS CloudWatch logs for application issues


