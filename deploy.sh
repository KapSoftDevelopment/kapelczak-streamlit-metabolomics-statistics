#!/bin/bash

# FBMN-STATS EasyPanel Deployment Script
# This script automates the deployment process for EasyPanel

set -e  # Exit on any error

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to validate environment
validate_environment() {
    print_status "Validating environment..."
    
    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    
    # Check available disk space (minimum 2GB)
    available_space=$(df . | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 2097152 ]; then
        print_warning "Low disk space detected. Ensure at least 2GB is available."
    fi
    
    print_success "Environment validation passed"
}

# Function to build and deploy
deploy_application() {
    print_status "Starting deployment..."
    
    # Stop existing containers if running
    if docker-compose ps | grep -q "fbmn-stats"; then
        print_status "Stopping existing containers..."
        docker-compose down
    fi
    
    # Build and start containers
    print_status "Building Docker images..."
    docker-compose build --no-cache
    
    print_status "Starting containers..."
    docker-compose up -d
    
    # Wait for application to be ready
    print_status "Waiting for application to start..."
    sleep 30
    
    # Health check
    max_attempts=10
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8502/_stcore/health >/dev/null 2>&1; then
            print_success "Application is healthy and ready!"
            break
        else
            print_status "Attempt $attempt/$max_attempts: Waiting for application..."
            sleep 10
            attempt=$((attempt + 1))
        fi
    done
    
    if [ $attempt -gt $max_attempts ]; then
        print_error "Application failed to start properly. Check logs with: docker-compose logs"
        exit 1
    fi
}

# Function to display deployment info
show_deployment_info() {
    print_success "Deployment completed successfully!"
    echo
    echo "=== Deployment Information ==="
    echo "Application URL: http://localhost:8502"
    echo "Health Check: http://localhost:8502/_stcore/health"
    echo
    echo "=== Useful Commands ==="
    echo "View logs: docker-compose logs -f fbmn-stats"
    echo "Stop application: docker-compose down"
    echo "Restart application: docker-compose restart"
    echo "View status: docker-compose ps"
    echo
    echo "=== EasyPanel Integration ==="
    echo "1. Copy this repository to your EasyPanel instance"
    echo "2. Use the docker-compose.yml file for deployment"
    echo "3. Configure domain in easypanel.yml"
    echo "4. Set up SSL through EasyPanel dashboard"
    echo
}

# Function to cleanup on failure
cleanup() {
    print_warning "Cleaning up due to failure..."
    docker-compose down 2>/dev/null || true
    exit 1
}

# Main deployment function
main() {
    echo "=== FBMN-STATS EasyPanel Deployment ==="
    echo
    
    # Set trap for cleanup on failure
    trap cleanup ERR
    
    # Check if we're in the right directory
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found. Please run this script from the project root directory."
        exit 1
    fi
    
    # Run deployment steps
    check_prerequisites
    validate_environment
    deploy_application
    show_deployment_info
    
    print_success "Deployment script completed successfully!"
}

# Parse command line arguments
case "${1:-}" in
    "--help" | "-h")
        echo "FBMN-STATS Deployment Script"
        echo
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --check        Only check prerequisites"
        echo "  --logs         Show application logs"
        echo "  --stop         Stop the application"
        echo "  --restart      Restart the application"
        echo
        exit 0
        ;;
    "--check")
        check_prerequisites
        validate_environment
        print_success "All checks passed!"
        exit 0
        ;;
    "--logs")
        docker-compose logs -f fbmn-stats
        exit 0
        ;;
    "--stop")
        print_status "Stopping application..."
        docker-compose down
        print_success "Application stopped"
        exit 0
        ;;
    "--restart")
        print_status "Restarting application..."
        docker-compose restart
        print_success "Application restarted"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac