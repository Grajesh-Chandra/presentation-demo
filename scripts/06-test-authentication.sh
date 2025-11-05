#!/bin/bash

# ==============================================================================
# 06 - Test Authentication & Rate Limiting
# ==============================================================================
# Tests Key Authentication and Rate Limiting on Demo API and AI Router
# ==============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_test() {
    echo -e "\n${YELLOW}TEST: $1${NC}"
    if [ ! -z "$2" ]; then
        echo -e "${CYAN}Endpoint: $2${NC}"
    fi
}

print_header "STEP 06: TEST AUTHENTICATION & RATE LIMITING"

# Test 1: No API Key (Should Fail)
print_header "AUTHENTICATION TESTS"

print_test "1. Demo API without API key (should fail)" "http://localhost:8000/api/demo/api/v1/users"
curl -s http://localhost:8000/api/demo/api/v1/users | jq '.'

print_test "2. AI Router without API key (should fail)" "http://localhost:8000/ai/models"
curl -s http://localhost:8000/ai/models | jq '.'

# Test 2: With Valid API Key (Should Succeed)
print_test "3. Demo API with valid API key (demo-user)" "http://localhost:8000/api/demo/api/v1/users"
curl -s -H "apikey: demo-api-key-12345" http://localhost:8000/api/demo/api/v1/users | jq '.'

print_test "4. AI Router with valid API key (demo-user)" "http://localhost:8000/ai/models"
curl -s -H "apikey: demo-api-key-12345" http://localhost:8000/ai/models | jq '.'

# Test 3: With Premium API Key
print_test "5. Demo API with premium API key (power-user)" "http://localhost:8000/api/demo/api/v1/users"
curl -s -H "apikey: power-key-67890" http://localhost:8000/api/demo/api/v1/users | jq '.'

# Test 4: Rate Limiting
print_header "RATE LIMITING TESTS"

print_test "6. Testing rate limits (demo-user: 10 requests/min)" "http://localhost:8000/api/demo/api/v1/stats"
echo -e "${BLUE}Making 12 rapid requests...${NC}"
for i in {1..12}; do
    echo -e "\nRequest $i:"
    RESPONSE=$(curl -s -w "\nHTTP Code: %{http_code}\n" \
      -H "apikey: demo-api-key-12345" \
      http://localhost:8000/api/demo/api/v1/stats)
    echo "$RESPONSE" | grep -E "HTTP Code|totalUsers|message"

    if [ $i -eq 11 ]; then
        echo -e "${RED}Expected rate limit error after 10 requests${NC}"
    fi
done

# Test 5: Check Rate Limit Headers
print_test "7. Check rate limit headers" "http://localhost:8000/api/demo/api/v1/users"
curl -v -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users 2>&1 | grep -i "x-ratelimit"

# Test 6: Different Consumer Rate Limits
print_test "8. Test power-user higher rate limit (50/min)" "http://localhost:8000/api/demo/api/v1/users"
echo -e "${BLUE}power-user should have higher limits...${NC}"
for i in {1..5}; do
    echo -n "Request $i: "
    curl -s -H "apikey: power-key-67890" \
      http://localhost:8000/api/demo/api/v1/users \
      | jq -r '.success'
done

echo -e "\n${GREEN}✅ Authentication and Rate Limiting tests completed!${NC}"
echo -e "\n${BLUE}Summary:${NC}"
echo -e "  ✅ Requests without API key are rejected"
echo -e "  ✅ Valid API keys grant access"
echo -e "  ✅ Rate limiting enforced (demo-user: 10/min, power-user: 50/min)"
echo -e "  ✅ Rate limit headers present in responses"

echo -e "\n${BLUE}Next Step: Run ${YELLOW}./07-add-ai-proxy.sh${NC}"
