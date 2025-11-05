#!/bin/bash

# ==============================================================================
# 02 - Test APIs Without Kong (Direct Access)
# ==============================================================================
# Tests Demo API and AI Router directly without Kong Gateway
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
NC='\033[0m'

# Configuration (with defaults if not in .env)
OLLAMA_HOST=${OLLAMA_HOST:-http://localhost:11434}
AI_ROUTER_URL=${AI_ROUTER_URL:-http://localhost:8080}
DEMO_API_URL=${DEMO_API_URL:-http://localhost:3000}

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
print_header "DEMO API TESTS ($DEMO_API_URL)"

print_test "1. Health Check" "$DEMO_API_URL/health"
curl -s $DEMO_API_URL/health | jq '.'

print_test "2. Get Users" "$DEMO_API_URL/api/v1/users"
curl -s $DEMO_API_URL/api/v1/users | jq '.'

print_test "3. Get User by ID" "$DEMO_API_URL/api/v1/users/1"
curl -s $DEMO_API_URL/api/v1/users/1 | jq '.'

print_test "4. Get Products" "$DEMO_API_URL/api/v1/products"
curl -s $DEMO_API_URL/api/v1/products | jq '.'

print_test "5. Get Statistics" "$DEMO_API_URL/api/v1/stats"
curl -s $DEMO_API_URL/api/v1/stats | jq '.'

# AI Router Tests
print_header "AI ROUTER TESTS ($AI_ROUTER_URL)"

print_test "6. Health Check" "$AI_ROUTER_URL/health"
curl -s $AI_ROUTER_URL/health | jq '.'

print_test "7. List Models" "$AI_ROUTER_URL/models"
curl -s $AI_ROUTER_URL/models | jq '.'

print_test "8. Chat with Mock Provider" "POST $AI_ROUTER_URL/chat"
curl -s -X POST $AI_ROUTER_URL/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"Hello","provider":"openai","model":"gpt-4"}' | jq '.'

print_test "9. Get Statistics" "$AI_ROUTER_URL/stats"
curl -s $AI_ROUTER_URL/stats | jq '.'

echo -e "\n${GREEN}✅ All direct API tests completed!${NC}"
echo -e "\n${BLUE}Next Steps:${NC}"
echo -e "  1. Deploy Kong Data Plane in Docker Desktop"
echo -e "  2. Connect to Konnect Control Plane"
echo -e "  3. Run ${YELLOW}./03-configure-kong-basic.sh${NC}"
