#!/bin/bash

# Frontend Deployment Script
# Usage: ./scripts/deploy-frontend.sh [dev|prod] [build-dir]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment is provided
if [ $# -lt 1 ]; then
    print_error "Usage: $0 [dev|prod] [build-dir]"
    print_status "Example: $0 dev ./build"
    exit 1
fi

ENVIRONMENT=$1
BUILD_DIR=${2:-"./build"}

# Validate environment
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    print_error "Environment must be 'dev' or 'prod'"
    exit 1
fi

print_status "Deploying frontend to $ENVIRONMENT environment..."

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    print_error "Build directory '$BUILD_DIR' not found"
    print_status "Please build your React app first: npm run build"
    exit 1
fi

# Check if index.html exists in build directory
if [ ! -f "$BUILD_DIR/index.html" ]; then
    print_error "index.html not found in $BUILD_DIR"
    print_status "Please ensure your React app is built correctly"
    exit 1
fi

# Get bucket name and distribution ID from Terraform output
ENV_DIR="env/$ENVIRONMENT"

if [ ! -d "$ENV_DIR" ]; then
    print_error "Environment directory $ENV_DIR not found"
    exit 1
fi

cd "$ENV_DIR"

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    print_error "Terraform state not found. Please deploy infrastructure first."
    exit 1
fi

# Get bucket name and distribution ID
BUCKET_NAME=$(terraform output -raw frontend_s3_bucket_name 2>/dev/null || echo "")
DISTRIBUTION_ID=$(terraform output -raw frontend_cloudfront_distribution_id 2>/dev/null || echo "")

if [ -z "$BUCKET_NAME" ]; then
    print_error "Could not get S3 bucket name from Terraform output"
    exit 1
fi

if [ -z "$DISTRIBUTION_ID" ]; then
    print_error "Could not get CloudFront distribution ID from Terraform output"
    exit 1
fi

print_status "S3 Bucket: $BUCKET_NAME"
print_status "CloudFront Distribution: $DISTRIBUTION_ID"

# Upload files to S3
print_status "Uploading files to S3..."
aws s3 sync "$BUILD_DIR" "s3://$BUCKET_NAME" --delete

if [ $? -eq 0 ]; then
    print_success "Files uploaded to S3 successfully!"
else
    print_error "Failed to upload files to S3"
    exit 1
fi

# Invalidate CloudFront cache
print_status "Invalidating CloudFront cache..."
INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$DISTRIBUTION_ID" \
    --paths "/*" \
    --query 'Invalidation.Id' \
    --output text)

if [ $? -eq 0 ]; then
    print_success "CloudFront cache invalidation created: $INVALIDATION_ID"
    
    # Wait for invalidation to complete
    print_status "Waiting for cache invalidation to complete..."
    aws cloudfront wait invalidation-completed \
        --distribution-id "$DISTRIBUTION_ID" \
        --id "$INVALIDATION_ID"
    
    print_success "Cache invalidation completed!"
else
    print_error "Failed to create CloudFront cache invalidation"
    exit 1
fi

# Get CloudFront domain name
CLOUDFRONT_DOMAIN=$(terraform output -raw frontend_cloudfront_domain_name 2>/dev/null || echo "")

if [ -n "$CLOUDFRONT_DOMAIN" ]; then
    print_success "Frontend deployed successfully!"
    print_status "Your application is available at: https://$CLOUDFRONT_DOMAIN"
else
    print_success "Frontend deployed successfully!"
    print_status "Please check the CloudFront distribution domain name in Terraform outputs"
fi

