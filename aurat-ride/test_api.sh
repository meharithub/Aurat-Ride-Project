#!/bin/bash

# API Testing Script for Aurat Ride Backend
# Base URL
BASE_URL="https://riderbackend.vexronics.com/api"

echo "🚀 Testing Aurat Ride API Endpoints"
echo "=================================="

# Variables for authentication
TOKEN=""
USER_ID=""

# ==================== APP CONFIG APIs ====================
echo "📱 Testing App Config APIs..."
echo "=============================="

# Test App Config
echo "📱 Testing App Config..."
curl -X GET "$BASE_URL/app/config" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -w "\nStatus: %{http_code}\n\n"

# Test Terms
echo "📄 Testing Terms..."
curl -X GET "$BASE_URL/content/terms" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -w "\nStatus: %{http_code}\n\n"

# Test Privacy
echo "🔒 Testing Privacy..."
curl -X GET "$BASE_URL/content/privacy" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -w "\nStatus: %{http_code}\n\n"

# ==================== AUTHENTICATION APIs ====================
echo "🔐 Testing Authentication APIs..."
echo "================================="

# Test Register (with unique data)
echo "👤 Testing Register..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{
    \"name\": \"API Test User $(date +%s)\",
    \"email\": \"test$(date +%s)@example.com\",
    \"phone\": \"0300$(date +%s)\",
    \"password\": \"123456\",
    \"role\": \"Rider\",
    \"cnic\": \"12345-6789012-$(date +%s)\",
    \"gender\": \"Male\"
  }" \
  -w "\nStatus: %{http_code}")

echo "$REGISTER_RESPONSE"
echo ""

# Test Login (with existing credentials)
echo "🔑 Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "rider@example.com",
    "password": "123456"
  }' \
  -w "\nStatus: %{http_code}")

echo "$LOGIN_RESPONSE"
echo ""

# Extract token from login response
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [ -n "$TOKEN" ]; then
  echo "✅ Token extracted: ${TOKEN:0:20}..."
else
  echo "❌ Failed to extract token from login response"
  exit 1
fi

# Test Check Auth
echo "🔍 Testing Check Auth..."
curl -X GET "$BASE_URL/auth/check" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# Test Send OTP
echo "📱 Testing Send OTP..."
curl -X POST "$BASE_URL/auth/otp/send" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "type": "phone",
    "recipient": "03001234567"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test Verify OTP (this will likely fail without valid OTP)
echo "✅ Testing Verify OTP..."
curl -X POST "$BASE_URL/auth/otp/verify" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "recipient": "03001234567",
    "code": "123456"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# ==================== PROFILE APIs ====================
echo "👤 Testing Profile APIs..."
echo "=========================="

# Test Get Profile
echo "👤 Testing Get Profile..."
curl -X GET "$BASE_URL/user/me" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# Test Update Profile
echo "✏️ Testing Update Profile..."
curl -X PUT "$BASE_URL/user/me" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Updated Test User"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test Update Gender
echo "⚧ Testing Update Gender..."
curl -X POST "$BASE_URL/user/gender" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "gender": "Female"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# ==================== RIDE BOOKING APIs ====================
echo "🚖 Testing Ride Booking APIs..."
echo "==============================="

# Test Get Ride Quote
echo "💰 Testing Get Ride Quote..."
curl -X POST "$BASE_URL/rides/quote" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "pickup_lat": 24.8607,
    "pickup_lng": 67.0011,
    "dropoff_lat": 24.9000,
    "dropoff_lng": 67.0500
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test Request Ride
echo "🚗 Testing Request Ride..."
RIDE_RESPONSE=$(curl -s -X POST "$BASE_URL/rides/request" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "pickup_lat": 24.8607,
    "pickup_lng": 67.0011,
    "pickup_address": "Clifton, Karachi",
    "dropoff_lat": 24.9000,
    "dropoff_lng": 67.0500,
    "dropoff_address": "DHA, Karachi"
  }' \
  -w "\nStatus: %{http_code}")

echo "$RIDE_RESPONSE"
echo ""

# Extract ride ID from response
RIDE_ID=$(echo "$RIDE_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
if [ -n "$RIDE_ID" ]; then
  echo "✅ Ride ID extracted: $RIDE_ID"
else
  echo "⚠️ No ride ID found, using placeholder"
  RIDE_ID="1"
fi

# Test Get All Rides
echo "📋 Testing Get All Rides..."
curl -X GET "$BASE_URL/rides" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# Test Get Specific Ride
echo "🔍 Testing Get Specific Ride..."
curl -X GET "$BASE_URL/rides/$RIDE_ID" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# Test Cancel Ride
echo "❌ Testing Cancel Ride..."
curl -X POST "$BASE_URL/rides/$RIDE_ID/cancel" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# Test Start Ride (Driver only)
echo "🚀 Testing Start Ride..."
curl -X POST "$BASE_URL/rides/$RIDE_ID/start" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# Test Complete Ride (Driver only)
echo "🏁 Testing Complete Ride..."
curl -X POST "$BASE_URL/rides/$RIDE_ID/complete" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# Test Live Tracking
echo "📍 Testing Live Tracking..."
curl -X GET "$BASE_URL/rides/$RIDE_ID/live" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

# ==================== DRIVER APIs ====================
echo "🚗 Testing Driver APIs..."
echo "========================="

# Test Update Driver Status
echo "🟢 Testing Update Driver Status..."
curl -X POST "$BASE_URL/driver/online" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "is_online": true
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test Update Driver Location
echo "📍 Testing Update Driver Location..."
curl -X POST "$BASE_URL/driver/location" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "lat": 24.8607,
    "lng": 67.0011
  }' \
  -w "\nStatus: %{http_code}\n\n"

# ==================== RATING & SUPPORT APIs ====================
echo "⭐ Testing Rating & Support APIs..."
echo "=================================="

# Test Rate Ride
echo "⭐ Testing Rate Ride..."
curl -X POST "$BASE_URL/rides/$RIDE_ID/rate" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "rating": 5,
    "comment": "Great ride!"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test Contact Support
echo "📞 Testing Contact Support..."
curl -X POST "$BASE_URL/support/contact" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "subject": "Test Support Request",
    "message": "This is a test support message",
    "name": "Test User",
    "email": "test@example.com"
  }' \
  -w "\nStatus: %{http_code}\n\n"

# Test Logout
echo "🚪 Testing Logout..."
curl -X POST "$BASE_URL/auth/logout" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -w "\nStatus: %{http_code}\n\n"

echo "✅ COMPREHENSIVE API TESTING COMPLETE!"
echo "======================================"
echo ""
echo "📊 SUMMARY:"
echo "   - App Config APIs: 3 tested"
echo "   - Authentication APIs: 6 tested"
echo "   - Profile APIs: 3 tested"
echo "   - Ride Booking APIs: 7 tested"
echo "   - Driver APIs: 2 tested"
echo "   - Rating & Support APIs: 2 tested"
echo "   - Total: 24 APIs tested"
echo ""
echo "🎯 All available APIs have been tested!"
echo "📋 Check the status codes above to see which APIs are working."
