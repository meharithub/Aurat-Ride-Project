#!/bin/bash

# Production API Test Script for Aurat Ride
# Tests all implemented APIs for production readiness

BASE_URL="https://riderbackend.vexronics.com/api"
USER_EMAIL="test@example.com"
USER_PASSWORD="password123"
DRIVER_EMAIL="driver@example.com"
DRIVER_PASSWORD="password123"

echo "🚀 Testing Production APIs for Aurat Ride"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test API endpoint
test_api() {
    local method=$1
    local endpoint=$2
    local data=$3
    local headers=$4
    local expected_status=$5
    local test_name=$6
    
    echo -n "Testing $test_name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -H "Content-Type: application/json" $headers "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method -H "Content-Type: application/json" $headers -d "$data" "$BASE_URL$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $http_code)"
        echo "Response: $body"
        ((TESTS_FAILED++))
    fi
}

# Get auth token
echo "🔐 Getting authentication token..."
auth_response=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"email\":\"$USER_EMAIL\",\"password\":\"$USER_PASSWORD\"}" \
    "$BASE_URL/auth/login")

token=$(echo $auth_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$token" ]; then
    echo -e "${RED}❌ Failed to get auth token. Please check credentials.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Authentication successful${NC}"
echo ""

# Test headers
AUTH_HEADER="-H \"Authorization: Bearer $token\""

echo "🧪 Testing Core APIs..."
echo "======================="

# Test existing APIs
test_api "GET" "/auth/check" "" "$AUTH_HEADER" "200" "Check Authentication"
test_api "GET" "/user/me" "" "$AUTH_HEADER" "200" "Get User Profile"
test_api "GET" "/app/config" "" "" "200" "Get App Configuration"
test_api "POST" "/rides/quote" '{"pickup_lat":24.8607,"pickup_lng":67.0011,"dropoff_lat":24.8607,"dropoff_lng":67.0011}' "" "200" "Get Ride Quote"

echo ""
echo "💳 Testing Payment APIs..."
echo "=========================="

test_api "GET" "/user/payment-methods" "" "$AUTH_HEADER" "200" "Get Payment Methods"
test_api "POST" "/user/payment-methods" '{"type":"card","details":"1234"}' "$AUTH_HEADER" "200" "Add Payment Method"
test_api "GET" "/user/wallet" "" "$AUTH_HEADER" "200" "Get Wallet Balance"
test_api "POST" "/user/wallet" '{"amount":100,"payment_method_id":"test123"}' "$AUTH_HEADER" "200" "Add Money to Wallet"
test_api "GET" "/user/transactions" "" "$AUTH_HEADER" "200" "Get Transaction History"

echo ""
echo "🚗 Testing Driver APIs..."
echo "========================"

test_api "GET" "/driver/earnings" "" "$AUTH_HEADER" "200" "Get Driver Earnings"
test_api "GET" "/driver/stats" "" "$AUTH_HEADER" "200" "Get Driver Statistics"
test_api "GET" "/drivers/nearby?lat=24.8607&lng=67.0011&radius=5" "" "" "200" "Get Nearby Drivers"

echo ""
echo "📍 Testing Location APIs..."
echo "==========================="

test_api "GET" "/user/favorites" "" "$AUTH_HEADER" "200" "Get Favorite Locations"
test_api "POST" "/user/favorites" '{"name":"Test Location","lat":24.8607,"lng":67.0011,"address":"Test Address"}' "$AUTH_HEADER" "200" "Add Favorite Location"
test_api "GET" "/user/recent-locations" "" "$AUTH_HEADER" "200" "Get Recent Locations"

echo ""
echo "🔔 Testing Notification APIs..."
echo "=============================="

test_api "GET" "/user/notifications" "" "$AUTH_HEADER" "200" "Get Notifications"
test_api "POST" "/user/notifications/1/read" "" "$AUTH_HEADER" "200" "Mark Notification as Read"

echo ""
echo "🚨 Testing Safety APIs..."
echo "========================"

test_api "POST" "/emergency/sos" '{"lat":24.8607,"lng":67.0011,"message":"Test emergency"}' "$AUTH_HEADER" "200" "Send Emergency SOS"
test_api "POST" "/safety/report" '{"ride_id":"1","issue_type":"driver_behavior","description":"Test safety report"}' "$AUTH_HEADER" "200" "Report Safety Issue"

echo ""
echo "📊 Test Results Summary"
echo "======================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Production APIs are ready.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please check the API implementations.${NC}"
    exit 1
fi
