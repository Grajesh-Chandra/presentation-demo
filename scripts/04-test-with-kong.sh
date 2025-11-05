#!/bin/bash

# ==============================================================================
# 04 - Test APIs Through Kong Gateway
# ==============================================================================
# Tests Demo API and AI Router through Kong Gateway (no auth yet)
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
}

print_header "STEP 04: TEST APIS THROUGH KONG"

# Check Kong is accessible
echo -e "${BLUE}Checking Kong Gateway...${NC}"
if curl -s http://localhost:8000 &>/dev/null; then
    echo -e "${GREEN}✅ Kong Gateway is accessible at http://localhost:8000${NC}\n"
else
    echo -e "${RED}❌ Kong Gateway is not accessible${NC}"
    echo -e "${YELLOW}Make sure Kong Data Plane is running in Docker${NC}"
    exit 1
fi

# Demo API Tests via Kong
print_header "DEMO API TESTS (via Kong)"

print_test "1. Health Check"
curl -s http://localhost:8000/api/demo/health | jq '.'

print_test "2. Get Users"
curl -s http://localhost:8000/api/demo/api/v1/users | jq '.'

print_test "3. Get User by ID"
curl -s http://localhost:8000/api/demo/api/v1/users/1 | jq '.'

print_test "4. Get Products"
curl -s http://localhost:8000/api/demo/api/v1/products | jq '.'

print_test "5. Get Statistics"
curl -s http://localhost:8000/api/demo/api/v1/stats | jq '.'

# AI Router Tests via Kong
print_header "AI ROUTER TESTS (via Kong)"

print_test "6. Health Check"
curl -s http://localhost:8000/ai/health | jq '.'

print_test "7. List Models"
curl -s http://localhost:8000/ai/models | jq '.'

print_test "8. Chat with Mock Provider"
curl -s -X POST http://localhost:8000/ai/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"Hello from Kong","provider":"openai","model":"gpt-4"}' | jq '.'

print_test "9. Get Statistics"
curl -s http://localhost:8000/ai/stats | jq '.'

echo -e "\n${GREEN}✅ All Kong routing tests completed!${NC}"
echo -e "\n${BLUE}Next Step: Run ${YELLOW}./05-add-authentication.sh${NC}"
