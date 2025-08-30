#!/bin/bash

# Book Review Infrastructure Deployment Script
# Usage: ./scripts/deploy.sh [dev|prod] [plan|apply|destroy]

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

# Check if environment and action are provided
if [ $# -lt 2 ]; then
    print_error "Usage: $0 [dev|prod] [plan|apply|destroy]"
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2

# Validate environment
if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
    print_error "Environment must be 'dev' or 'prod'"
    exit 1
fi

# Validate action
if [[ "$ACTION" != "plan" && "$ACTION" != "apply" && "$ACTION" != "destroy" ]]; then
    print_error "Action must be 'plan', 'apply', or 'destroy'"
    exit 1
fi

# Set environment-specific variables
ENV_DIR="env/$ENVIRONMENT"
TFVARS_FILE="$ENV_DIR/terraform.tfvars"

print_status "Deploying to $ENVIRONMENT environment..."

# Check if terraform.tfvars exists
if [ ! -f "$TFVARS_FILE" ]; then
    print_warning "terraform.tfvars not found in $ENV_DIR"
    print_status "Please copy terraform.tfvars.example to terraform.tfvars and configure it"
    exit 1
fi

# Change to environment directory
cd "$ENV_DIR"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform >= 1.0"
    exit 1
fi

# Check Terraform version
TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
print_status "Using Terraform version: $TF_VERSION"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Perform the requested action
case $ACTION in
    "plan")
        print_status "Planning Terraform deployment..."
        terraform plan
        ;;
    "apply")
        print_warning "This will create/modify AWS resources. Are you sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Applying Terraform configuration..."
            terraform apply -auto-approve
            print_success "Deployment completed successfully!"
            
            # Show outputs
            print_status "Deployment outputs:"
            terraform output
        else
            print_status "Deployment cancelled"
            exit 0
        fi
        ;;
    "destroy")
        print_warning "This will DESTROY all AWS resources. Are you absolutely sure? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_warning "Please confirm by typing 'destroy' to proceed:"
            read -r confirm
            if [[ "$confirm" == "destroy" ]]; then
                print_status "Destroying infrastructure..."
                terraform destroy -auto-approve
                print_success "Infrastructure destroyed successfully!"
            else
                print_status "Destruction cancelled"
                exit 0
            fi
        else
            print_status "Destruction cancelled"
            exit 0
        fi
        ;;
esac

print_success "Operation completed!"


