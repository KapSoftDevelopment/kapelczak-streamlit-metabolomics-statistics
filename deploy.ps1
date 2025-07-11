# FBMN-STATS EasyPanel Deployment Script (PowerShell)
# This script automates the deployment process for EasyPanel on Windows

param(
    [switch]$Help,
    [switch]$Check,
    [switch]$Logs,
    [switch]$Stop,
    [switch]$Restart
)

# Function to print colored output
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

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Status "Checking prerequisites..."
    
    if (-not (Test-Command "docker")) {
        Write-Error "Docker is not installed. Please install Docker Desktop first."
        exit 1
    }
    
    if (-not (Test-Command "docker-compose")) {
        Write-Error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    }
    
    Write-Success "Prerequisites check passed"
}

# Function to validate environment
function Test-Environment {
    Write-Status "Validating environment..."
    
    # Check if Docker daemon is running
    try {
        docker info | Out-Null
    }
    catch {
        Write-Error "Docker daemon is not running. Please start Docker Desktop first."
        exit 1
    }
    
    # Check available disk space (minimum 2GB)
    $drive = (Get-Location).Drive
    $freeSpace = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$($drive.Name)'").FreeSpace
    if ($freeSpace -lt 2GB) {
        Write-Warning "Low disk space detected. Ensure at least 2GB is available."
    }
    
    Write-Success "Environment validation passed"
}

# Function to build and deploy
function Start-Deployment {
    Write-Status "Starting deployment..."
    
    # Stop existing containers if running
    $runningContainers = docker-compose ps --services --filter "status=running"
    if ($runningContainers -contains "fbmn-stats") {
        Write-Status "Stopping existing containers..."
        docker-compose down
    }
    
    # Build and start containers
    Write-Status "Building Docker images..."
    docker-compose build --no-cache
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to build Docker images"
        exit 1
    }
    
    Write-Status "Starting containers..."
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to start containers"
        exit 1
    }
    
    # Wait for application to be ready
    Write-Status "Waiting for application to start..."
    Start-Sleep -Seconds 30
    
    # Health check
    $maxAttempts = 10
    $attempt = 1
    
    while ($attempt -le $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8502/_stcore/health" -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Success "Application is healthy and ready!"
                break
            }
        }
        catch {
            Write-Status "Attempt $attempt/$maxAttempts`: Waiting for application..."
            Start-Sleep -Seconds 10
            $attempt++
        }
    }
    
    if ($attempt -gt $maxAttempts) {
        Write-Error "Application failed to start properly. Check logs with: docker-compose logs"
        exit 1
    }
}

# Function to display deployment info
function Show-DeploymentInfo {
    Write-Success "Deployment completed successfully!"
    Write-Host ""
    Write-Host "=== Deployment Information ===" -ForegroundColor Cyan
    Write-Host "Application URL: http://localhost:8502"
    Write-Host "Health Check: http://localhost:8502/_stcore/health"
    Write-Host ""
    Write-Host "=== Useful Commands ===" -ForegroundColor Cyan
    Write-Host "View logs: docker-compose logs -f fbmn-stats"
    Write-Host "Stop application: docker-compose down"
    Write-Host "Restart application: docker-compose restart"
    Write-Host "View status: docker-compose ps"
    Write-Host ""
    Write-Host "=== EasyPanel Integration ===" -ForegroundColor Cyan
    Write-Host "1. Copy this repository to your EasyPanel instance"
    Write-Host "2. Use the docker-compose.yml file for deployment"
    Write-Host "3. Configure domain in easypanel.yml"
    Write-Host "4. Set up SSL through EasyPanel dashboard"
    Write-Host ""
}

# Function to show help
function Show-Help {
    Write-Host "FBMN-STATS Deployment Script (PowerShell)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\deploy.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help          Show this help message"
    Write-Host "  -Check         Only check prerequisites"
    Write-Host "  -Logs          Show application logs"
    Write-Host "  -Stop          Stop the application"
    Write-Host "  -Restart       Restart the application"
    Write-Host ""
}

# Main deployment function
function Start-Main {
    Write-Host "=== FBMN-STATS EasyPanel Deployment ===" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if we're in the right directory
    if (-not (Test-Path "docker-compose.yml")) {
        Write-Error "docker-compose.yml not found. Please run this script from the project root directory."
        exit 1
    }
    
    # Run deployment steps
    Test-Prerequisites
    Test-Environment
    Start-Deployment
    Show-DeploymentInfo
    
    Write-Success "Deployment script completed successfully!"
}

# Parse command line arguments and execute appropriate function
if ($Help) {
    Show-Help
    exit 0
}
elseif ($Check) {
    Test-Prerequisites
    Test-Environment
    Write-Success "All checks passed!"
    exit 0
}
elseif ($Logs) {
    docker-compose logs -f fbmn-stats
    exit 0
}
elseif ($Stop) {
    Write-Status "Stopping application..."
    docker-compose down
    Write-Success "Application stopped"
    exit 0
}
elseif ($Restart) {
    Write-Status "Restarting application..."
    docker-compose restart
    Write-Success "Application restarted"
    exit 0
}
else {
    Start-Main
}