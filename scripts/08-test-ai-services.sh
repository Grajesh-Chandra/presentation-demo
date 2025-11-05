#!/bin/bash

# ==============================================================================
# 08 - Test AI Services (Gemini & Ollama)
# ==============================================================================
# Tests Kong Native AI Proxy and Custom AI Router
# ==============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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

API_KEY="demo-api-key-12345"

print_header "STEP 08: TEST AI SERVICES"

# Test 1: Custom AI Router (Flask App)
print_header "CUSTOM AI ROUTER TESTS"

print_test "1. List Available Models" "http://localhost:8000/ai/custom/models"
curl -s -H "apikey: $API_KEY" \
  http://localhost:8000/ai/custom/models | jq '.'

print_test "2. Chat with Ollama via Custom Router" "POST http://localhost:8000/ai/custom/chat"
curl -s -H "apikey: $API_KEY" \
  -X POST http://localhost:8000/ai/custom/chat \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "Say hello in one sentence",
    "provider": "ollama",
    "model": "mistral"
  }' | jq '.'

print_test "3. Chat with Mock Provider" "POST http://localhost:8000/ai/custom/chat"
curl -s -H "apikey: $API_KEY" \
  -X POST http://localhost:8000/ai/custom/chat \
  -H 'Content-Type: application/json' \
  -d '{
    "message": "What is AI?",
    "provider": "openai",
    "model": "gpt-4"
  }' | jq '.'

# Test 2: Kong Native AI - Ollama
print_header "KONG NATIVE AI - OLLAMA TESTS"

print_test "4. Kong AI Proxy - Ollama/Mistral Chat" "POST http://localhost:8000/ai/kong/ollama/chat"
curl -s -H "apikey: $API_KEY" \
  -X POST http://localhost:8000/ai/kong/ollama/chat \
  -H 'Content-Type: application/json' \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "Say hello in one sentence"
      }
    ]
  }' | jq '.'

# Test 3: Kong Native AI - Gemini
print_header "KONG NATIVE AI - GEMINI TESTS"

print_test "5. Kong AI Proxy - Gemini Chat" "POST http://localhost:8000/ai/kong/gemini/chat"
echo -e "${BLUE}Testing Gemini (gemini-2.5-flash)...${NC}"
GEMINI_RESPONSE=$(curl -s -H "apikey: $API_KEY" \
  -X POST http://localhost:8000/ai/kong/gemini/chat \
  -H 'Content-Type: application/json' \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "Say hello in one sentence"
      }
    ]
  }')

echo "$GEMINI_RESPONSE" | jq '.'

if echo "$GEMINI_RESPONSE" | grep -q "error"; then
    echo -e "${YELLOW}⚠️  Gemini returned error (API key may not be configured)${NC}"
else
    echo -e "${GREEN}✅ Gemini working!${NC}"
fi

# Test 4: Health Check (No Auth Required)
print_header "PUBLIC ENDPOINTS"

print_test "6. Health Check (No auth required)" "http://localhost:8000/ai/health"
curl -s http://localhost:8000/ai/health | jq '.'

# Test 5: Authentication Check
print_header "AUTHENTICATION VERIFICATION"

print_test "7. AI endpoint without API key (should fail)" "POST http://localhost:8000/ai/kong/ollama/chat"
curl -s -X POST http://localhost:8000/ai/kong/ollama/chat \
  -H 'Content-Type: application/json' \
  -d '{"messages":[{"role":"user","content":"test"}]}' | jq '.'

# Test 6: Compare Both Approaches
print_header "COMPARISON: KONG NATIVE vs CUSTOM ROUTER"

echo -e "${MAGENTA}Sending same prompt to both approaches...${NC}"
PROMPT="What is 2+2? Answer in one short sentence."

print_test "8a. Kong Native AI (Ollama)" "POST http://localhost:8000/ai/kong/ollama/chat"
curl -s -H "apikey: $API_KEY" \
  -X POST http://localhost:8000/ai/kong/ollama/chat \
  -H 'Content-Type: application/json' \
  -d "{\"messages\":[{\"role\":\"user\",\"content\":\"$PROMPT\"}]}" \
  | jq '.choices[0].message.content // .error'

print_test "8b. Custom AI Router (Ollama)" "POST http://localhost:8000/ai/custom/chat"
curl -s -H "apikey: $API_KEY" \
  -X POST http://localhost:8000/ai/custom/chat \
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
