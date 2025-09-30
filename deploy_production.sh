#!/bin/bash

# Production Deployment Script for Aurat Ride
# This script sets up the complete production environment

echo "🚀 Deploying Aurat Ride to Production"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -d "riderbackend.vexronics.com" ]; then
    echo -e "${RED}❌ Error: Please run this script from the project root directory${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Step 1: Setting up Laravel Backend${NC}"
cd riderbackend.vexronics.com

# Install dependencies
echo "Installing PHP dependencies..."
composer install --optimize-autoloader --no-dev

# Generate application key
echo "Generating application key..."
php artisan key:generate

# Run migrations
echo "Running database migrations..."
php artisan migrate --force

# Cache configuration
echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Create storage symlink
echo "Creating storage symlink..."
php artisan storage:link

echo -e "${GREEN}✅ Backend setup complete${NC}"

echo -e "${YELLOW}📋 Step 2: Setting up Flutter App${NC}"
cd ../aurat-ride

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build for production
echo "Building Flutter app for production..."
flutter build apk --release
flutter build ios --release

echo -e "${GREEN}✅ Flutter app build complete${NC}"

echo -e "${YELLOW}📋 Step 3: Running Production Tests${NC}"
cd ..

# Run API tests
echo "Testing production APIs..."
cd aurat-ride
if [ -f "test_production_apis.sh" ]; then
    chmod +x test_production_apis.sh
    ./test_production_apis.sh
else
    echo -e "${YELLOW}⚠️  API test script not found${NC}"
fi

echo -e "${GREEN}🎉 Production deployment complete!${NC}"
echo ""
echo "📱 Next steps:"
echo "1. Upload the built APK/IPA to app stores"
echo "2. Configure web server for Laravel backend"
echo "3. Set up SSL certificates"
echo "4. Configure push notifications"
echo "5. Set up monitoring and logging"
