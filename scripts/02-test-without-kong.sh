#!/bin/bash

# ==============================================================================
# 02 - Test APIs Without Kong (Direct Access)
# ==============================================================================
# Tests Demo API and AI Router directly without Kong Gateway
# ==============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header "STEP 02: TEST APIS WITHOUT KONG"

# Demo API Tests
print_header "DEMO API TESTS (http://localhost:3000)"

print_test "1. Health Check" "http://localhost:3000/health"
curl -s http://localhost:3000/health | jq '.'

print_test "2. Get Users" "http://localhost:3000/api/v1/users"
curl -s http://localhost:3000/api/v1/users | jq '.'

print_test "3. Get User by ID" "http://localhost:3000/api/v1/users/1"
curl -s http://localhost:3000/api/v1/users/1 | jq '.'

print_test "4. Get Products" "http://localhost:3000/api/v1/products"
curl -s http://localhost:3000/api/v1/products | jq '.'

print_test "5. Get Statistics" "http://localhost:3000/api/v1/stats"
curl -s http://localhost:3000/api/v1/stats | jq '.'

# AI Router Tests
print_header "AI ROUTER TESTS (http://localhost:8080)"

print_test "6. Health Check" "http://localhost:8080/health"
curl -s http://localhost:8080/health | jq '.'

print_test "7. List Models" "http://localhost:8080/models"
curl -s http://localhost:8080/models | jq '.'

print_test "8. Chat with Mock Provider" "POST http://localhost:8080/chat"
curl -s -X POST http://localhost:8080/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"Hello","provider":"openai","model":"gpt-4"}' | jq '.'

print_test "9. Get Statistics" "http://localhost:8080/stats"
curl -s http://localhost:8080/stats | jq '.'

echo -e "\n${GREEN}✅ All direct API tests completed!${NC}"
echo -e "\n${BLUE}Next Steps:${NC}"
echo -e "  1. Deploy Kong Data Plane in Docker Desktop"
echo -e "  2. Connect to Konnect Control Plane"
echo -e "  3. Run ${YELLOW}./03-configure-kong-basic.sh${NC}"
