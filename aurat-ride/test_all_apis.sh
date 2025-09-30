#!/bin/bash

# Comprehensive API Test Script for Production Ready App
# This script tests all implemented APIs to ensure they work perfectly

echo "🚀 Starting Comprehensive API Testing for Production Ready App"
echo "=============================================================="

# Base URL
BASE_URL="http://127.0.0.1:8000/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local method="$2"
    local url="$3"
    local data="$4"
    local headers="$5"
    local expected_status="$6"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "\n${BLUE}Testing: $test_name${NC}"
    echo "URL: $method $url"
    
    if [ -n "$data" ]; then
        echo "Data: $data"
    fi
    
    # Make the request
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" $headers "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" $headers -d "$data" "$url")
    fi
    
    # Extract status code and body
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed $d)
    
    echo "Status: $status_code"
    echo "Response: $body"
    
    # Check if test passed
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAILED - Expected $expected_status, got $status_code${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to get auth token
get_auth_token() {
    echo -e "\n${YELLOW}Getting authentication token...${NC}"
    
    # Try to login first (in case user already exists)
    login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d '{
            "email": "apitest2@example.com",
            "password": "password123"
        }')
    
    echo "Login response: $login_response"
    
    # Extract token
    AUTH_TOKEN=$(echo "$login_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    # If login failed, try to register
    if [ -z "$AUTH_TOKEN" ]; then
        echo -e "${YELLOW}Login failed, trying to register...${NC}"
        
        # Register a test user
        register_response=$(curl -s -X POST "$BASE_URL/auth/register" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d '{
                "name": "API Test User 2",
                "email": "apitest2@example.com",
                "phone": "+1234567898",
                "password": "password123",
                "role": "Rider",
                "gender": "Male",
                "cnic": "12345-1234567-8"
            }')
        
        echo "Register response: $register_response"
        
        # Try login again after registration
        login_response=$(curl -s -X POST "$BASE_URL/auth/login" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d '{
                "email": "apitest2@example.com",
                "password": "password123"
            }')
        
        echo "Login response after registration: $login_response"
        
        # Extract token
        AUTH_TOKEN=$(echo "$login_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    fi
    
    if [ -n "$AUTH_TOKEN" ]; then
        echo -e "${GREEN}✅ Authentication successful${NC}"
        echo "Token: $AUTH_TOKEN"
    else
        echo -e "${RED}❌ Authentication failed${NC}"
        exit 1
    fi
}

# Get authentication token
get_auth_token

# Set auth headers
AUTH_HEADERS="-H 'Accept: application/json' -H 'Authorization: Bearer $AUTH_TOKEN'"

echo -e "\n${YELLOW}Starting API Tests...${NC}"

# ==================== AUTHENTICATION TESTS ====================
echo -e "\n${YELLOW}=== AUTHENTICATION TESTS ===${NC}"

run_test "Check Authentication" "GET" "$BASE_URL/auth/check" "" "$AUTH_HEADERS" "200"
run_test "Logout" "POST" "$BASE_URL/auth/logout" "" "$AUTH_HEADERS" "200"

# ==================== USER PROFILE TESTS ====================
echo -e "\n${YELLOW}=== USER PROFILE TESTS ===${NC}"

run_test "Get User Profile" "GET" "$BASE_URL/user/profile" "" "$AUTH_HEADERS" "200"
run_test "Update User Profile" "PUT" "$BASE_URL/user/profile" '{"name": "Updated Test User"}' "$AUTH_HEADERS" "200"

# ==================== APP CONFIG TESTS ====================
echo -e "\n${YELLOW}=== APP CONFIG TESTS ===${NC}"

run_test "Get App Config" "GET" "$BASE_URL/app/config" "" "-H 'Accept: application/json'" "200"
run_test "Get Terms" "GET" "$BASE_URL/content/terms" "" "-H 'Accept: application/json'" "200"
run_test "Get Privacy" "GET" "$BASE_URL/content/privacy" "" "-H 'Accept: application/json'" "200"

# ==================== RIDE TESTS ====================
echo -e "\n${YELLOW}=== RIDE TESTS ===${NC}"

run_test "Get Ride Quote" "POST" "$BASE_URL/rides/quote" '{
    "pickup_lat": 24.8607,
    "pickup_lng": 67.0011,
    "dropoff_lat": 24.8607,
    "dropoff_lng": 67.0011
}' "-H 'Accept: application/json'" "200"

run_test "Request Ride" "POST" "$BASE_URL/rides/request" '{
    "pickup_lat": 24.8607,
    "pickup_lng": 67.0011,
    "pickup_address": "Test Pickup",
    "dropoff_lat": 24.8607,
    "dropoff_lng": 67.0011,
    "dropoff_address": "Test Dropoff",
    "polyline": "test_polyline"
}' "$AUTH_HEADERS" "200"

run_test "Get User Rides" "GET" "$BASE_URL/user/rides" "" "$AUTH_HEADERS" "200"

# ==================== PAYMENT TESTS ====================
echo -e "\n${YELLOW}=== PAYMENT TESTS ===${NC}"

run_test "Get Payment Methods" "GET" "$BASE_URL/user/payment-methods" "" "$AUTH_HEADERS" "200"
run_test "Add Payment Method" "POST" "$BASE_URL/user/payment-methods" '{
    "type": "card",
    "details": {
        "last_four": "1234",
        "brand": "visa"
    }
}' "$AUTH_HEADERS" "200"

run_test "Get Wallet Balance" "GET" "$BASE_URL/user/wallet" "" "$AUTH_HEADERS" "200"
run_test "Add to Wallet" "POST" "$BASE_URL/user/wallet" '{
    "amount": 100.00,
    "payment_method_id": 1
}' "$AUTH_HEADERS" "200"

run_test "Get Transaction History" "GET" "$BASE_URL/user/transactions" "" "$AUTH_HEADERS" "200"

# ==================== LOCATION TESTS ====================
echo -e "\n${YELLOW}=== LOCATION TESTS ===${NC}"

run_test "Get Favorite Locations" "GET" "$BASE_URL/user/favorites" "" "$AUTH_HEADERS" "200"
run_test "Add Favorite Location" "POST" "$BASE_URL/user/favorites" '{
    "name": "Home",
    "lat": 24.8607,
    "lng": 67.0011,
    "address": "Test Address"
}' "$AUTH_HEADERS" "200"

run_test "Get Recent Locations" "GET" "$BASE_URL/user/recent-locations" "" "$AUTH_HEADERS" "200"

# ==================== NOTIFICATION TESTS ====================
echo -e "\n${YELLOW}=== NOTIFICATION TESTS ===${NC}"

run_test "Get Notifications" "GET" "$BASE_URL/user/notifications" "" "$AUTH_HEADERS" "200"

# ==================== DRIVER TESTS ====================
echo -e "\n${YELLOW}=== DRIVER TESTS ===${NC}"

run_test "Set Driver Online" "POST" "$BASE_URL/driver/online" '{"is_online": true}' "$AUTH_HEADERS" "200"
run_test "Update Driver Location" "POST" "$BASE_URL/driver/location" '{
    "lat": 24.8607,
    "lng": 67.0011
}' "$AUTH_HEADERS" "200"

run_test "Get Driver Earnings" "GET" "$BASE_URL/driver/earnings" "" "$AUTH_HEADERS" "200"
run_test "Get Driver Stats" "GET" "$BASE_URL/driver/stats" "" "$AUTH_HEADERS" "200"

# ==================== RATING TESTS ====================
echo -e "\n${YELLOW}=== RATING TESTS ===${NC}"

run_test "Rate Ride" "POST" "$BASE_URL/rides/1/rate" '{
    "rating": 5,
    "comment": "Great ride!"
}' "$AUTH_HEADERS" "200"

run_test "Get User Ratings" "GET" "$BASE_URL/user/ratings" "" "$AUTH_HEADERS" "200"

# ==================== SUPPORT TESTS ====================
echo -e "\n${YELLOW}=== SUPPORT TESTS ===${NC}"

run_test "Send Support Message" "POST" "$BASE_URL/support/contact" '{
    "subject": "Test Support",
    "message": "This is a test support message"
}' "$AUTH_HEADERS" "200"

# ==================== SAFETY TESTS ====================
echo -e "\n${YELLOW}=== SAFETY TESTS ===${NC}"

run_test "Send Emergency SOS" "POST" "$BASE_URL/emergency/sos" '{
    "lat": 24.8607,
    "lng": 67.0011,
    "message": "Emergency test"
}' "$AUTH_HEADERS" "200"

run_test "Report Safety Issue" "POST" "$BASE_URL/safety/report" '{
    "ride_id": 1,
    "issue_type": "driver_behavior",
    "description": "Test safety report"
}' "$AUTH_HEADERS" "200"

# ==================== CHAT TESTS ====================
echo -e "\n${YELLOW}=== CHAT TESTS ===${NC}"

run_test "Get Ride Messages" "GET" "$BASE_URL/rides/1/messages" "" "$AUTH_HEADERS" "200"
run_test "Send Ride Message" "POST" "$BASE_URL/rides/1/messages" '{
    "message": "Hello, this is a test message",
    "type": "text"
}' "$AUTH_HEADERS" "200"
run_test "Mark Messages as Read" "POST" "$BASE_URL/rides/1/messages/read" "" "$AUTH_HEADERS" "200"
run_test "Get Unread Count" "GET" "$BASE_URL/rides/1/messages/unread-count" "" "$AUTH_HEADERS" "200"

# ==================== PUBLIC TESTS ====================
echo -e "\n${YELLOW}=== PUBLIC TESTS ===${NC}"

run_test "Get Nearby Drivers" "GET" "$BASE_URL/drivers/nearby?lat=24.8607&lng=67.0011&radius=5" "" "-H 'Accept: application/json'" "200"

# ==================== RESULTS ====================
echo -e "\n${YELLOW}=== TEST RESULTS ===${NC}"
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! The app is production ready! 🎉${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please check the issues above.${NC}"
    exit 1
fi
