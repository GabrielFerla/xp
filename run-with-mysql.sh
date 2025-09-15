#!/bin/bash

# =====================================================
# XP Application - MySQL Setup Script
# Description: Script to run XP Application with MySQL database
# Author: XP Development Team
# Date: 2024-01-15
# =====================================================

echo "🚀 Starting XP Application with MySQL..."

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if MySQL container is running
if ! docker ps | grep -q "xp-mysql"; then
    print_status "Starting MySQL container..."
    docker-compose -f docker-compose-mysql.yml up -d mysql
    
    # Wait for MySQL to be ready
    print_status "Waiting for MySQL to be ready..."
    sleep 30
    
    # Check if MySQL is ready
    if ! docker exec xp-mysql mysqladmin ping -h localhost --silent; then
        print_error "MySQL is not ready. Please check the container logs."
        exit 1
    fi
    
    print_success "MySQL container is running!"
else
    print_success "MySQL container is already running!"
fi

# Check if phpMyAdmin container is running
if ! docker ps | grep -q "xp-phpmyadmin"; then
    print_status "Starting phpMyAdmin container..."
    docker-compose -f docker-compose-mysql.yml up -d phpmyadmin
    print_success "phpMyAdmin is available at http://localhost:8081"
else
    print_success "phpMyAdmin is already running at http://localhost:8081"
fi

# Display connection information
echo ""
print_status "Database Connection Information:"
echo "  Host: localhost"
echo "  Port: 3306"
echo "  Database: xpdb"
echo "  Username: xp_user"
echo "  Password: xp_password"
echo ""
print_status "phpMyAdmin: http://localhost:8081"
echo "  Username: xp_user"
echo "  Password: xp_password"
echo ""

# Ask user which profile to run
echo "Select the profile to run:"
echo "1) MySQL Development (application-mysql.properties)"
echo "2) MySQL Production (application-prod.properties)"
echo "3) H2 Development (application.properties) - Default"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        PROFILE="mysql"
        print_status "Running with MySQL Development profile..."
        ;;
    2)
        PROFILE="prod"
        print_status "Running with MySQL Production profile..."
        ;;
    3|"")
        PROFILE=""
        print_status "Running with H2 Development profile (default)..."
        ;;
    *)
        print_error "Invalid choice. Running with default H2 profile..."
        PROFILE=""
        ;;
esac

# Run the application
if [ -n "$PROFILE" ]; then
    print_status "Starting XP Application with profile: $PROFILE"
    ./mvnw spring-boot:run -Dspring-boot.run.profiles=$PROFILE
else
    print_status "Starting XP Application with default profile"
    ./mvnw spring-boot:run
fi

print_success "XP Application started successfully!"
echo ""
print_status "Application URLs:"
echo "  Application: https://localhost:8080"
echo "  Swagger UI: https://localhost:8080/swagger-ui.html"
echo "  Health Check: https://localhost:8080/actuator/health"
echo "  ESB Info: https://localhost:8080/api/esb/info"
echo ""
print_status "To stop the application, press Ctrl+C"
print_status "To stop MySQL containers, run: docker-compose -f docker-compose-mysql.yml down"
