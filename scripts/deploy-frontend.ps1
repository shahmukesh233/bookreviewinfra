# Frontend Deployment Script (PowerShell)
# Usage: .\scripts\deploy-frontend.ps1 [dev|prod] [build-dir]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "./build"
)

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Status "Deploying frontend to $Environment environment..."

# Check if build directory exists
if (-not (Test-Path $BuildDir)) {
    Write-Error "Build directory '$BuildDir' not found"
    Write-Status "Please build your React app first: npm run build"
    exit 1
}

# Check if index.html exists in build directory
if (-not (Test-Path "$BuildDir\index.html")) {
    Write-Error "index.html not found in $BuildDir"
    Write-Status "Please ensure your React app is built correctly"
    exit 1
}

# Get bucket name and distribution ID from Terraform output
$EnvDir = "env\$Environment"

if (-not (Test-Path $EnvDir)) {
    Write-Error "Environment directory $EnvDir not found"
    exit 1
}

Set-Location $EnvDir

# Check if Terraform state exists
if (-not (Test-Path "terraform.tfstate")) {
    Write-Error "Terraform state not found. Please deploy infrastructure first."
    exit 1
}

# Get bucket name and distribution ID
try {
    $BucketName = terraform output -raw frontend_s3_bucket_name
    $DistributionId = terraform output -raw frontend_cloudfront_distribution_id
} catch {
    Write-Error "Could not get Terraform outputs. Please ensure infrastructure is deployed."
    exit 1
}

if (-not $BucketName) {
    Write-Error "Could not get S3 bucket name from Terraform output"
    exit 1
}

if (-not $DistributionId) {
    Write-Error "Could not get CloudFront distribution ID from Terraform output"
    exit 1
}

Write-Status "S3 Bucket: $BucketName"
Write-Status "CloudFront Distribution: $DistributionId"

# Upload files to S3
Write-Status "Uploading files to S3..."
try {
    aws s3 sync $BuildDir "s3://$BucketName" --delete
    Write-Success "Files uploaded to S3 successfully!"
} catch {
    Write-Error "Failed to upload files to S3"
    exit 1
}

# Invalidate CloudFront cache
Write-Status "Invalidating CloudFront cache..."
try {
    $InvalidationId = aws cloudfront create-invalidation --distribution-id $DistributionId --paths "/*" --query 'Invalidation.Id' --output text
    Write-Success "CloudFront cache invalidation created: $InvalidationId"
    
    # Wait for invalidation to complete
    Write-Status "Waiting for cache invalidation to complete..."
    aws cloudfront wait invalidation-completed --distribution-id $DistributionId --id $InvalidationId
    Write-Success "Cache invalidation completed!"
} catch {
    Write-Error "Failed to create CloudFront cache invalidation"
    exit 1
}

# Get CloudFront domain name
try {
    $CloudFrontDomain = terraform output -raw frontend_cloudfront_domain_name
    if ($CloudFrontDomain) {
        Write-Success "Frontend deployed successfully!"
        Write-Status "Your application is available at: https://$CloudFrontDomain"
    } else {
        Write-Success "Frontend deployed successfully!"
        Write-Status "Please check the CloudFront distribution domain name in Terraform outputs"
    }
} catch {
    Write-Success "Frontend deployed successfully!"
    Write-Status "Please check the CloudFront distribution domain name in Terraform outputs"
}

