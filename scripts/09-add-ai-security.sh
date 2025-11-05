#!/bin/bash

# ==============================================================================
# 09 - Add AI Security (Prompt Guard & Response Transformer)
# ==============================================================================
# Adds AI Prompt Guard, Response Transformer, and additional security plugins
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

print_header "STEP 09: ADD AI SECURITY PLUGINS"

# Get Gemini API key from previous config or ask
if [ -f "plugins/03-kong-with-ai-proxy.yaml" ]; then
    GEMINI_KEY=$(grep "header_value:" plugins/03-kong-with-ai-proxy.yaml | head -1 | cut -d'"' -f2)
else
    echo -e "${YELLOW}Enter Gemini API Key (or press Enter to skip):${NC}"
    read -p "Gemini API Key: " GEMINI_KEY
    if [ -z "$GEMINI_KEY" ]; then
        GEMINI_KEY="\$(GEMINI_API_KEY)"
    fi
fi

# Create complete Kong configuration with all security
cat > plugins/04-kong-complete.yaml << EOF
_format_version: "3.0"
_konnect:
  control_plane_name: Kong-Demo

# ==============================================================================
# SERVICES & ROUTES
# ==============================================================================
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

  # Custom AI Router
  - name: custom-ai-router
    url: http://host.docker.internal:8080
    tags:
      - ai-router
      - custom
    routes:
      - name: custom-ai-chat
        paths:
          - /ai/custom
        strip_path: true
        methods:
          - GET
          - POST

      - name: custom-ai-health
        paths:
          - /ai/health
        strip_path: true
        methods:
          - GET

# ==============================================================================
# CONSUMERS & CREDENTIALS
# ==============================================================================
consumers:
  - username: demo-user
    custom_id: user-001
    tags:
      - demo
      - basic-tier
    keyauth_credentials:
      - key: demo-api-key-12345

  - username: power-user
    custom_id: user-002
    tags:
      - premium
      - power-tier
    keyauth_credentials:
      - key: power-key-67890

# ==============================================================================
# PLUGINS
# ==============================================================================
plugins:
  # --------------------------------------------------------------------------
  # Key Authentication
  # --------------------------------------------------------------------------
  - name: key-auth
    route: demo-api-route
    config:
      key_names: [apikey]
      hide_credentials: true

  - name: key-auth
    route: custom-ai-chat
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

  # --------------------------------------------------------------------------
  # Rate Limiting
  # --------------------------------------------------------------------------
  - name: rate-limiting
    consumer: demo-user
    config:
      minute: 10
      hour: 100
      policy: local
      fault_tolerant: true

  - name: rate-limiting
    consumer: power-user
    config:
      minute: 50
      hour: 500
      policy: local
      fault_tolerant: true

  # --------------------------------------------------------------------------
  # AI Prompt Guard - Security for AI routes
  # --------------------------------------------------------------------------
  - name: ai-prompt-guard
    service: ollama-ai-service
    config:
      allow_patterns:
        - ".*"
      deny_patterns:
        - "(?i)(ignore previous instructions)"
        - "(?i)(ignore all previous)"
        - "(?i)(system prompt)"
        - "(?i)(jailbreak)"
        - "(?i)(act as.*DAN)"
        - "(?i)(you are no longer)"
      max_request_body_size: 8192

  - name: ai-prompt-guard
    service: gemini-ai-service
    config:
      allow_patterns:
        - ".*"
      deny_patterns:
        - "(?i)(ignore previous instructions)"
        - "(?i)(ignore all previous)"
        - "(?i)(system prompt)"
        - "(?i)(jailbreak)"
        - "(?i)(act as.*DAN)"
        - "(?i)(you are no longer)"
      max_request_body_size: 8192

  # --------------------------------------------------------------------------
  # Response Transformer - Add custom headers
  # --------------------------------------------------------------------------
  - name: response-transformer
    route: custom-ai-chat
    config:
      add:
        headers:
          - "X-AI-Gateway-Mode:custom"
          - "X-Powered-By:Kong-Gateway"

  - name: response-transformer
    route: ollama-chat-route
    config:
      add:
        headers:
          - "X-AI-Gateway-Mode:native"
          - "X-AI-Provider:ollama"
          - "X-Powered-By:Kong-AI-Gateway"

  - name: response-transformer
    route: gemini-chat-route
    config:
      add:
        headers:
          - "X-AI-Gateway-Mode:native"
          - "X-AI-Provider:gemini"
          - "X-Powered-By:Kong-AI-Gateway"

  # --------------------------------------------------------------------------
  # Correlation ID - Track requests
  # --------------------------------------------------------------------------
  - name: correlation-id
    config:
      header_name: X-Request-ID
      generator: uuid
      echo_downstream: true

  # --------------------------------------------------------------------------
  # Request Size Limiting - Prevent abuse
  # --------------------------------------------------------------------------
  - name: request-size-limiting
    service: ollama-ai-service
    config:
      allowed_payload_size: 10
      size_unit: megabytes

  - name: request-size-limiting
    service: gemini-ai-service
    config:
      allowed_payload_size: 10
      size_unit: megabytes

  - name: request-size-limiting
    service: custom-ai-router
    config:
      allowed_payload_size: 10
      size_unit: megabytes
EOF

echo -e "${GREEN}✅ Complete configuration created: plugins/04-kong-complete.yaml${NC}\n"

echo -e "${MAGENTA}Security Plugins Added:${NC}"
echo -e "  ✅ AI Prompt Guard - Blocks malicious prompts"
echo -e "     • Blocks jailbreak attempts"
echo -e "     • Blocks prompt injection"
echo -e "     • Blocks DAN (Do Anything Now) attacks"
echo -e "  ✅ Response Transformer - Adds custom headers"
echo -e "  ✅ Request Size Limiting - Max 10MB payloads"
echo -e "  ✅ Correlation ID - Request tracking"

echo -e "\n${YELLOW}To apply this configuration, run:${NC}"
echo -e "${GREEN}deck gateway sync \\"
echo -e "  --konnect-control-plane-name='Kong-Demo' \\"
echo -e "  --konnect-addr='https://in.api.konghq.com' \\"
echo -e "  --konnect-token='YOUR_TOKEN' \\"
echo -e "  ../plugins/04-kong-complete.yaml${NC}"

echo -e "\n${BLUE}After applying, run: ${YELLOW}./10-test-security.sh${NC}"
