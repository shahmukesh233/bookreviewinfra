# Book Review Infrastructure Deployment Script (PowerShell)
# Usage: .\scripts\deploy.ps1 [dev|prod] [plan|apply|destroy]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action
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

# Set environment-specific variables
$EnvDir = "env\$Environment"
$TfVarsFile = "$EnvDir\terraform.tfvars"

Write-Status "Deploying to $Environment environment..."

# Check if terraform.tfvars exists
if (-not (Test-Path $TfVarsFile)) {
    Write-Warning "terraform.tfvars not found in $EnvDir"
    Write-Status "Please copy terraform.tfvars.example to terraform.tfvars and configure it"
    exit 1
}

# Change to environment directory
Set-Location $EnvDir

# Check if Terraform is installed
try {
    $TfVersion = terraform version -json | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version
    Write-Status "Using Terraform version: $TfVersion"
} catch {
    Write-Error "Terraform is not installed. Please install Terraform >= 1.0"
    exit 1
}

# Initialize Terraform if needed
if (-not (Test-Path ".terraform")) {
    Write-Status "Initializing Terraform..."
    terraform init
}

# Perform the requested action
switch ($Action) {
    "plan" {
        Write-Status "Planning Terraform deployment..."
        terraform plan
    }
    "apply" {
        Write-Warning "This will create/modify AWS resources. Are you sure? (y/N)"
        $response = Read-Host
        if ($response -match "^[yY](es)?$") {
            Write-Status "Applying Terraform configuration..."
            terraform apply -auto-approve
            Write-Success "Deployment completed successfully!"
            
            # Show outputs
            Write-Status "Deployment outputs:"
            terraform output
        } else {
            Write-Status "Deployment cancelled"
            exit 0
        }
    }
    "destroy" {
        Write-Warning "This will DESTROY all AWS resources. Are you absolutely sure? (y/N)"
        $response = Read-Host
        if ($response -match "^[yY](es)?$") {
            Write-Warning "Please confirm by typing 'destroy' to proceed:"
            $confirm = Read-Host
            if ($confirm -eq "destroy") {
                Write-Status "Destroying infrastructure..."
                terraform destroy -auto-approve
                Write-Success "Infrastructure destroyed successfully!"
            } else {
                Write-Status "Destruction cancelled"
                exit 0
            }
        } else {
            Write-Status "Destruction cancelled"
            exit 0
        }
    }
}

Write-Success "Operation completed!"


