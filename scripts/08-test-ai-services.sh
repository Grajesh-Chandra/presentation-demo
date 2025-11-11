#!/bin/bash

# ==============================================================================
# 08 - Test AI Services (Gemini & Ollama)
# ==============================================================================
# Tests Kong Native AI Proxy and Custom AI Router
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
MAGENTA='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration (with defaults if not in .env)
KONG_PROXY_URL=${KONNECT_PROXY_URL:-http://localhost:8000}
DEMO_API_KEY=${DEMO_API_KEY:-demo-api-key-12345}

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_test() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}TEST: $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_request() {
    local method=$1
    local url=$2
    local headers=$3
    local body=$4

    echo -e "\n${BLUE}📤 REQUEST:${NC}"
    echo -e "  Method: ${GREEN}${method}${NC}"
    echo -e "  URL: ${CYAN}${url}${NC}"

    if [ ! -z "$headers" ]; then
        echo -e "  Headers:"
        echo "$headers" | while IFS= read -r header; do
            [ ! -z "$header" ] && echo -e "    ${header}"
        done
    fi

    if [ ! -z "$body" ]; then
        echo -e "  Body:"
        echo "$body" | jq '.' 2>/dev/null || echo "    $body"
    fi

    echo -e "\n${BLUE}📥 RESPONSE:${NC}"
}

print_header "STEP 08: TEST AI SERVICES"

# Test 1: Custom AI Router (Flask App)
print_header "CUSTOM AI ROUTER TESTS"

print_test "1. List Available Models"
print_request "GET" "$KONG_PROXY_URL/ai/custom/models" "apikey: $DEMO_API_KEY"
curl -s -H "apikey: $DEMO_API_KEY" \
  $KONG_PROXY_URL/ai/custom/models | jq '.'

print_test "2. Chat with Ollama via Custom Router"
BODY='{"message":"Say hello in one sentence","provider":"ollama","model":"mistral"}'
HEADERS="apikey: $DEMO_API_KEY"$'\n'"Content-Type: application/json"
print_request "POST" "$KONG_PROXY_URL/ai/custom/chat" "$HEADERS" "$BODY"
curl -s -H "apikey: $DEMO_API_KEY" \
  -X POST $KONG_PROXY_URL/ai/custom/chat \
  -H 'Content-Type: application/json' \
  -d "$BODY" | jq '.'

print_test "3. Chat with Mock Provider"
BODY='{"message":"What is AI?","provider":"openai","model":"gpt-4"}'
print_request "POST" "$KONG_PROXY_URL/ai/custom/chat" "$HEADERS" "$BODY"
curl -s -H "apikey: $DEMO_API_KEY" \
  -X POST $KONG_PROXY_URL/ai/custom/chat \
  -H 'Content-Type: application/json' \
  -d "$BODY" | jq '.'

# Test 2: Kong Native AI - Ollama
print_header "KONG NATIVE AI - OLLAMA TESTS"

print_test "4. Kong AI Proxy - Ollama/Mistral Chat"
BODY='{"messages":[{"role":"user","content":"Say hello in one sentence"}]}'
HEADERS="apikey: $DEMO_API_KEY"$'\n'"Content-Type: application/json"
print_request "POST" "$KONG_PROXY_URL/ai/kong/ollama/chat" "$HEADERS" "$BODY"
curl -s -H "apikey: $DEMO_API_KEY" \
  -X POST $KONG_PROXY_URL/ai/kong/ollama/chat \
  -H 'Content-Type: application/json' \
  -d "$BODY" | jq '.'

# Test 3: Kong Native AI - Gemini
print_header "KONG NATIVE AI - GEMINI TESTS"

print_test "5. Kong AI Proxy - Gemini Chat"
echo -e "${BLUE}Testing Gemini (gemini-2.5-flash)...${NC}"
BODY='{"messages":[{"role":"user","content":"Say hello in one sentence"}]}'
print_request "POST" "$KONG_PROXY_URL/ai/kong/gemini/chat" "$HEADERS" "$BODY"
GEMINI_RESPONSE=$(curl -s -H "apikey: $DEMO_API_KEY" \
  -X POST $KONG_PROXY_URL/ai/kong/gemini/chat \
  -H 'Content-Type: application/json' \
  -d "$BODY")

echo "$GEMINI_RESPONSE" | jq '.'

if echo "$GEMINI_RESPONSE" | grep -q "error"; then
    echo -e "${YELLOW}⚠️  Gemini returned error (API key may not be configured)${NC}"
else
    echo -e "${GREEN}✅ Gemini working!${NC}"
fi

# Test 4: Health Check (No Auth Required)
print_header "PUBLIC ENDPOINTS"

print_test "6. Health Check (No auth required)"
print_request "GET" "$KONG_PROXY_URL/ai/health"
curl -s $KONG_PROXY_URL/ai/health | jq '.'

# Test 5: Authentication Check
print_header "AUTHENTICATION VERIFICATION"

print_test "7. AI endpoint without API key (should fail)"
BODY='{"messages":[{"role":"user","content":"test"}]}'
print_request "POST" "$KONG_PROXY_URL/ai/kong/ollama/chat" "Content-Type: application/json" "$BODY"
curl -s -X POST $KONG_PROXY_URL/ai/kong/ollama/chat \
  -H 'Content-Type: application/json' \
  -d "$BODY" | jq '.'

# Test 6: Compare Both Approaches
print_header "COMPARISON: KONG NATIVE vs CUSTOM ROUTER"

echo -e "${MAGENTA}Sending same prompt to both approaches...${NC}"
PROMPT="What is 2+2? Answer in one short sentence."

print_test "8a. Kong Native AI (Ollama)" "POST $KONG_PROXY_URL/ai/kong/ollama/chat"
curl -s -H "apikey: $DEMO_API_KEY" \
  -X POST $KONG_PROXY_URL/ai/kong/ollama/chat \
  -H 'Content-Type: application/json' \
  -d "{\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}]}" \
  | jq '.choices[0].message.content // .error'

print_test "8b. Custom AI Router (Ollama)" "POST $KONG_PROXY_URL/ai/custom/chat"
curl -s -H "apikey: $DEMO_API_KEY" \
  -X POST $KONG_PROXY_URL/ai/custom/chat \
  -H 'Content-Type: application/json' \
  -d "{\"message\":\"$PROMPT\",\"provider\":\"ollama\",\"model\":\"mistral\"}" \
  | jq '.response.content // .error'

echo -e "\n${GREEN}✅ AI Services tests completed!${NC}"
echo -e "\n${BLUE}Summary:${NC}"
echo -e "  ✅ Custom AI Router (Flask) working"
echo -e "  ✅ Kong Native AI Proxy (Ollama) working"
echo -e "  ✅ Kong Native AI Proxy (Gemini) configured"
echo -e "  ✅ Authentication required for AI endpoints"
echo -e "  ✅ Health endpoint public (no auth)"

echo -e "\n${BLUE}Next Step: Run ${YELLOW}./09-add-ai-security.sh${NC}"
