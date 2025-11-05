#!/bin/bash

# ==============================================================================
# 04 - Test APIs Through Kong Gateway
# ==============================================================================
# Tests Demo API and AI Router through Kong Gateway (no auth yet)
# ==============================================================================

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
    echo "✅ Environment loaded from .env"
else
    echo "⚠️  Warning: .env file not found, using defaults"
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration (with defaults if not in .env)
KONG_PROXY_URL=${KONNECT_PROXY_URL:-http://localhost:8000}

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

print_header "STEP 04: TEST APIS THROUGH KONG"

# Check Kong is accessible
echo -e "${BLUE}Checking Kong Gateway...${NC}"
if curl -s $KONG_PROXY_URL &>/dev/null; then
    echo -e "${GREEN}✅ Kong Gateway is accessible at $KONG_PROXY_URL${NC}\n"
else
    echo -e "${RED}❌ Kong Gateway is not accessible at $KONG_PROXY_URL${NC}"
    echo -e "${YELLOW}Make sure Kong Data Plane is running in Docker${NC}"
    exit 1
fi

# Demo API Tests via Kong
print_header "DEMO API TESTS (via Kong)"

print_test "1. Health Check" "$KONG_PROXY_URL/api/demo/health"
curl -s $KONG_PROXY_URL/api/demo/health | jq '.'

print_test "2. Get Users" "$KONG_PROXY_URL/api/demo/api/v1/users"
curl -s $KONG_PROXY_URL/api/demo/api/v1/users | jq '.'

print_test "3. Get User by ID" "$KONG_PROXY_URL/api/demo/api/v1/users/1"
curl -s $KONG_PROXY_URL/api/demo/api/v1/users/1 | jq '.'

print_test "4. Get Products" "$KONG_PROXY_URL/api/demo/api/v1/products"
curl -s $KONG_PROXY_URL/api/demo/api/v1/products | jq '.'

print_test "5. Get Statistics" "$KONG_PROXY_URL/api/demo/api/v1/stats"
curl -s $KONG_PROXY_URL/api/demo/api/v1/stats | jq '.'

# AI Router Tests via Kong
print_header "AI ROUTER TESTS (via Kong)"

print_test "6. Health Check" "$KONG_PROXY_URL/ai/health"
curl -s $KONG_PROXY_URL/ai/health | jq '.'

print_test "7. List Models" "$KONG_PROXY_URL/ai/models"
curl -s $KONG_PROXY_URL/ai/models | jq '.'

print_test "8. Chat with Mock Provider" "POST $KONG_PROXY_URL/ai/chat"
curl -s -X POST $KONG_PROXY_URL/ai/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"Hello from Kong","provider":"openai","model":"gpt-4"}' | jq '.'

print_test "9. Get Statistics" "$KONG_PROXY_URL/ai/stats"
curl -s $KONG_PROXY_URL/ai/stats | jq '.'

echo -e "\n${GREEN}✅ All Kong routing tests completed!${NC}"
echo -e "\n${BLUE}Next Step: Run ${YELLOW}./05-add-authentication.sh${NC}"
