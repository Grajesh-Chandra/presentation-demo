#!/bin/bash

# ==============================================================================
# 07 - Add AI Proxy (Gemini & Ollama)
# ==============================================================================
# Adds Kong Native AI Gateway with ai-proxy plugin for Gemini and Ollama
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

cd "$(dirname "$0")/.." || exit 1

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ Environment loaded from .env${NC}\n"
else
    echo -e "${YELLOW}⚠️  .env file not found. Using placeholder for Gemini API key.${NC}\n"
fi

print_header "STEP 07: ADD AI PROXY PLUGINS"

# Use Gemini API key from .env or placeholder
if [ -z "$GEMINI_API_KEY" ]; then
    GEMINI_KEY="\$(GEMINI_API_KEY)"
    echo -e "${YELLOW}⚠️  GEMINI_API_KEY not found in .env. Using placeholder.${NC}"
    echo -e "${YELLOW}   Update .env with your Gemini API key and re-run this script.${NC}\n"
else
    GEMINI_KEY="$GEMINI_API_KEY"
    echo -e "${GREEN}✅ Using Gemini API key from .env${NC}\n"
fi

# Create Kong configuration with AI Proxy
cat > plugins/03-kong-with-ai-proxy.yaml << EOF
_format_version: "3.0"
_konnect:
  control_plane_name: Kong-Demo

services:
  # Kong Native AI - Ollama (Mistral)
  - name: ollama-ai-service
    url: http://host.docker.internal:11434
    tags:
      - ai-gateway
      - native
      - ollama
    routes:
      - name: ollama-chat-route
        paths:
          - /ai/kong/ollama/chat
        strip_path: false
        methods:
          - POST
        tags:
          - kong-ai
          - ollama
    plugins:
      - name: ai-proxy
        config:
          route_type: llm/v1/chat
          model:
            provider: llama2
            name: mistral
            options:
              upstream_url: http://host.docker.internal:11434/v1/chat/completions
              llama2_format: openai
          logging:
            log_statistics: true
            log_payloads: false

  # Kong Native AI - Google Gemini
  - name: gemini-ai-service
    url: https://generativelanguage.googleapis.com
    tags:
      - ai-gateway
      - native
      - gemini
    routes:
      - name: gemini-chat-route
        paths:
          - /ai/kong/gemini/chat
        strip_path: false
        methods:
          - POST
        tags:
          - kong-ai
          - gemini
    plugins:
      - name: ai-proxy
        config:
          route_type: llm/v1/chat
          model:
            provider: gemini
            name: gemini-2.5-flash
          auth:
            header_name: x-goog-api-key
            header_value: "${GEMINI_KEY}"
          logging:
            log_statistics: true
            log_payloads: false

  # Demo API Service
  - name: demo-api-service
    url: http://host.docker.internal:3000
    tags:
      - demo-api
    routes:
      - name: demo-api-route
        paths:
          - /api/demo
        strip_path: true

  # AI Router Service (Custom Flask App)
  - name: ai-router-service
    url: http://host.docker.internal:8080
    tags:
      - ai-router
      - custom
    routes:
      - name: ai-router-route
        paths:
          - /ai/custom
        strip_path: true
        methods:
          - GET
          - POST
        tags:
          - custom-ai

      - name: ai-health-route
        paths:
          - ~/ai/health$
        strip_path: false
        methods:
          - GET
        tags:
          - health
          - public
        plugins:
          - name: request-transformer
            config:
              replace:
                uri: /health

# Consumers
consumers:
  - username: demo-user
    custom_id: user-001
    keyauth_credentials:
      - key: demo-api-key-12345

  - username: power-user
    custom_id: user-002
    keyauth_credentials:
      - key: power-key-67890

# Plugins
plugins:
  # Key Authentication
  - name: key-auth
    route: demo-api-route
    config:
      key_names: [apikey]
      hide_credentials: true

  - name: key-auth
    route: ai-router-route
    config:
      key_names: [apikey]
      hide_credentials: true

  - name: key-auth
    route: ollama-chat-route
    config:
      key_names: [apikey]
      hide_credentials: true

  - name: key-auth
    route: gemini-chat-route
    config:
      key_names: [apikey]
      hide_credentials: true

  # Rate Limiting
  - name: rate-limiting
    consumer: demo-user
    config:
      minute: 10
      hour: 100
      policy: local

  - name: rate-limiting
    consumer: power-user
    config:
      minute: 50
      hour: 500
      policy: local

  # Correlation ID
  - name: correlation-id
    config:
      header_name: X-Request-ID
      generator: uuid
      echo_downstream: true
EOF

echo -e "${BLUE}Configuration created: plugins/03-kong-with-ai-proxy.yaml${NC}\n"

# Load token from .env if available
if [ -f ".env" ]; then
    source ".env"
elif [ -f "../.env" ]; then
    source "../.env"
fi

echo -e "\n${YELLOW}To apply this configuration, run:${NC}"
if [ -n "$DECK_KONNECT_TOKEN" ]; then
    echo -e "${GREEN}deck gateway sync \\"
    echo -e "  --konnect-control-plane-name='${DECK_KONNECT_CONTROL_PLANE_NAME}' \\"
    echo -e "  --konnect-addr='${KONNECT_CONTROL_PLANE_URL}' \\"
    echo -e "  --konnect-token='${DECK_KONNECT_TOKEN}' \\"
    echo -e "  ../plugins/03-kong-with-ai-proxy.yaml${NC}"
else
    echo -e "${GREEN}deck gateway sync \\"
    echo -e "  --konnect-control-plane-name='Kong-Demo' \\"
    echo -e "  --konnect-addr='https://in.api.konghq.com' \\"
    echo -e "  --konnect-token='YOUR_TOKEN' \\"
    echo -e "  ../plugins/03-kong-with-ai-proxy.yaml${NC}"
    echo -e "${YELLOW}Note: Add DECK_KONNECT_TOKEN to .env file to see actual token${NC}"
fi

echo -e "\n${MAGENTA}AI Services Added:${NC}"
echo -e "  ✅ Kong Native AI - Ollama (Mistral)"
echo -e "     Route: POST /ai/kong/ollama/chat"
echo -e "  ✅ Kong Native AI - Google Gemini (gemini-2.5-flash)"
echo -e "     Route: POST /ai/kong/gemini/chat"
echo -e "  ✅ Custom AI Router (Flask app)"
echo -e "     Route: POST /ai/custom/chat"

echo -e "\n${BLUE}Prerequisites:${NC}"
echo -e "  • Ollama must be running: ${YELLOW}ollama serve${NC}"
echo -e "  • Mistral model pulled: ${YELLOW}ollama pull mistral${NC}"
echo -e "  • Gemini API key configured (if you want to use Gemini)"

echo -e "\n${BLUE}After applying, run: ${YELLOW}./08-test-ai-services.sh${NC}"
