# 🚗 Aurat Ride - Local Backend Setup Guide

## 📋 Prerequisites

Before setting up the backend locally, ensure you have:

- **PHP 8.0+** with extensions: `php-mysql`, `php-mbstring`, `php-xml`, `php-curl`
- **Composer** (PHP dependency manager)
- **MySQL 5.7+** or **MariaDB 10.3+**
- **Node.js & NPM** (for frontend assets)

## 🗄️ Database Setup

### 1. Create Database
```sql
CREATE DATABASE vexrgehf_rideapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. Import Database Schema
```bash
mysql -u root -p vexrgehf_rideapp < vexrgehf_rideapp.sql
```

## 🔧 Backend Setup

### 1. Navigate to Backend Directory
```bash
cd /Volumes/Personal/Projects/Aurat-ride-project/riderbackend.vexronics.com
```

### 2. Install Dependencies
```bash
composer install
```

### 3. Generate Application Key
```bash
php artisan key:generate
```

### 4. Configure Environment
The `.env` file has been created with local settings. Update database credentials if needed:

```env
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vexrgehf_rideapp
DB_USERNAME=root
DB_PASSWORD=your_mysql_password
```

### 5. Run Migrations (if needed)
```bash
php artisan migrate
```

### 6. Create Storage Link
```bash
php artisan storage:link
```

### 7. Start Development Server
```bash
php artisan serve
```

The API will be available at: `http://127.0.0.1:8000/api`

## 📱 Flutter App Configuration

### 1. Update API Base URL
In `/Volumes/Personal/Projects/Aurat-ride-project/aurat-ride/lib/services/api_service.dart`:

```dart
// Change line 10 from:
static const String baseUrl = baseUrlLive;

// To:
static const String baseUrl = baseUrlLocal;
```

### 2. Run Flutter App
```bash
cd /Volumes/Personal/Projects/Aurat-ride-project/aurat-ride
flutter pub get
flutter run
```

## 🧪 Testing APIs

### Test Authentication
```bash
# Register a new user
curl -X POST http://127.0.0.1:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "03001234567",
    "password": "password123",
    "role": "Rider",
    "cnic": "12345-6789012-3",
    "gender": "Female"
  }'

# Login
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Test Ride Quote
```bash
curl -X POST http://127.0.0.1:8000/api/rides/quote \
  -H "Content-Type: application/json" \
  -d '{
    "pickup_lat": 31.5204,
    "pickup_lng": 74.3587,
    "dropoff_lat": 31.5497,
    "dropoff_lng": 74.3436
  }'
```

## 🔍 API Endpoints Overview

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/otp/send` - Send OTP
- `POST /api/auth/otp/verify` - Verify OTP
- `GET /api/auth/check` - Check auth status
- `POST /api/auth/logout` - Logout

### Rides
- `POST /api/rides/quote` - Get ride quote
- `POST /api/rides/request` - Request ride
- `GET /api/rides` - List rides
- `GET /api/rides/{id}` - Get specific ride
- `POST /api/rides/{id}/cancel` - Cancel ride
- `POST /api/rides/{id}/start` - Start ride (driver)
- `POST /api/rides/{id}/complete` - Complete ride (driver)

### Driver
- `POST /api/driver/online` - Set driver online/offline
- `POST /api/driver/location` - Update driver location
- `GET /api/rides/{id}/live` - Live ride tracking

### App
- `GET /api/app/config` - App configuration
- `GET /api/content/terms` - Terms and conditions
- `GET /api/content/privacy` - Privacy policy

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check MySQL service is running
   - Verify database credentials in `.env`
   - Ensure database exists

2. **Permission Denied (Storage)**
   ```bash
   chmod -R 775 storage/
   chmod -R 775 bootstrap/cache/
   ```

3. **Composer Issues**
   ```bash
   composer clear-cache
   composer install --no-dev
   ```

4. **Flutter API Connection**
   - Ensure backend is running on `http://127.0.0.1:8000`
   - Check API base URL in `api_service.dart`
   - Verify CORS settings in Laravel

## 📊 Database Schema

The database includes these main tables:
- `users` - User accounts (Riders/Drivers)
- `rides` - Ride requests and tracking
- `driver_locations` - Real-time driver positions
- `otps` - OTP verification codes
- `ratings` - User ratings
- `contact_messages` - Support messages
- `personal_access_tokens` - API authentication

## 🚀 Production Deployment

For production deployment:
1. Update `.env` with production settings
2. Set `APP_ENV=production`
3. Set `APP_DEBUG=false`
4. Configure proper database credentials
5. Set up SSL certificates
6. Configure web server (Apache/Nginx)
7. Set up proper file permissions

## 📞 Support

If you encounter any issues:
1. Check Laravel logs: `storage/logs/laravel.log`
2. Verify database connection
3. Check API endpoints with Postman/curl
4. Ensure all dependencies are installed
