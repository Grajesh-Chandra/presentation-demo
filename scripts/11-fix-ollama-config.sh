#!/bin/bash

# ==============================================================================
# 13 - Fix Ollama Configuration (Remove Semantic Cache)
# ==============================================================================
# Creates Kong config without ai-semantic-cache (not yet in Konnect)
# Uses llama2 provider type for Ollama compatibility
# ==============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment variables
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
    echo -e "${GREEN}✅ Environment loaded from .env${NC}"
else
    echo -e "${RED}❌ .env file not found${NC}"
    exit 1
fi

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Creating Kong Configuration (Ollama Compatible)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

OUTPUT_FILE="$PROJECT_ROOT/plugins/06-kong-with-ollama-fixed.yaml"

cat > "$OUTPUT_FILE" << 'EOF'
_format_version: "3.0"

services:
  # Demo API Service
  - name: demo-api-service
    url: http://host.docker.internal:3000
    routes:
      - name: demo-api-route
        paths:
          - /api/demo
        strip_path: true
        plugins:
          - name: key-auth
            config:
              key_names:
                - apikey
          - name: rate-limiting
            config:
              minute: 10
              policy: local
          - name: correlation-id
            config:
              header_name: Kong-Request-ID
              generator: uuid
              echo_downstream: true
          - name: response-transformer
            config:
              add:
                headers:
                  - "X-Kong-Demo:true"
                  - "X-Service:demo-api"

  # AI Router Service (Custom Flask App)
  - name: ai-router-service
    url: http://host.docker.internal:8080
    routes:
      # Public health endpoint
      - name: ai-health-route
        paths:
          - /ai/health
        strip_path: false
        plugins:
          - name: correlation-id
            config:
              header_name: Kong-Request-ID
              generator: uuid
              echo_downstream: true

      # Custom AI Router endpoints (with auth)
      - name: ai-custom-route
        paths:
          - /ai/custom
        strip_path: false
        plugins:
          - name: key-auth
            config:
              key_names:
                - apikey
          - name: rate-limiting
            config:
              minute: 20
              policy: local
          - name: correlation-id
            config:
              header_name: Kong-Request-ID
              generator: uuid
              echo_downstream: true
          - name: response-transformer
            config:
              add:
                headers:
                  - "X-Kong-Demo:true"
                  - "X-Service:ai-router-custom"

  # Kong Native AI - Ollama Service (using llama2 provider type)
  - name: ai-ollama-service
    url: http://host.docker.internal:11434
    routes:
      - name: ai-ollama-chat-route
        paths:
          - /ai/kong/ollama/chat
        strip_path: true
        plugins:
          - name: key-auth
            config:
              key_names:
                - apikey
          - name: rate-limiting
            config:
              minute: 20
              policy: local
          - name: ai-proxy
            config:
              route_type: "llm/v1/chat"
              auth:
                header_name: Authorization
                header_value: "Bearer dummy"
              logging:
                log_statistics: true
                log_payloads: false
              model:
                provider: "llama2"
                name: "mistral"
                options:
                  max_tokens: 512
                  temperature: 0.7
                  llama2_format: "openai"
                  upstream_url: "http://host.docker.internal:11434/v1/chat/completions"
          - name: ai-prompt-guard
            config:
              allow_patterns:
                - ".*"
              deny_patterns:
                - "ignore previous instructions"
                - "ignore all previous"
                - "act as DAN"
                - "do anything now"
                - "jailbreak"
                - "bypass"
          - name: correlation-id
            config:
              header_name: Kong-Request-ID
              generator: uuid
              echo_downstream: true
          - name: response-transformer
            config:
              add:
                headers:
                  - "X-Kong-Demo:true"
                  - "X-Service:ai-ollama"
                  - "X-AI-Provider:ollama"
          - name: request-size-limiting
            config:
              allowed_payload_size: 5

  # Kong Native AI - Gemini Service
  - name: ai-gemini-service
    url: https://generativelanguage.googleapis.com
    routes:
      - name: ai-gemini-chat-route
        paths:
          - /ai/kong/gemini/chat
        strip_path: true
        plugins:
          - name: key-auth
            config:
              key_names:
                - apikey
          - name: rate-limiting
            config:
              minute: 20
              policy: local
          - name: ai-proxy
            config:
              route_type: "llm/v1/chat"
              auth:
                header_name: "x-goog-api-key"
                header_value: "GEMINI_API_KEY_PLACEHOLDER"
              logging:
                log_statistics: true
                log_payloads: false
              model:
                provider: "gemini"
                name: "gemini-2.0-flash-exp"
                options:
                  max_tokens: 512
                  temperature: 0.7
          - name: ai-prompt-guard
            config:
              allow_patterns:
                - ".*"
              deny_patterns:
                - "ignore previous instructions"
                - "ignore all previous"
                - "act as DAN"
                - "do anything now"
                - "jailbreak"
                - "bypass"
          - name: correlation-id
            config:
              header_name: Kong-Request-ID
              generator: uuid
              echo_downstream: true
          - name: response-transformer
            config:
              add:
                headers:
                  - "X-Kong-Demo:true"
                  - "X-Service:ai-gemini"
                  - "X-AI-Provider:gemini"
          - name: request-size-limiting
            config:
              allowed_payload_size: 5

consumers:
  - username: demo-user
    keyauth_credentials:
      - key: demo-api-key-12345
    plugins:
      - name: rate-limiting
        config:
          minute: 10
          policy: local

  - username: power-user
    keyauth_credentials:
      - key: power-key-67890
    plugins:
      - name: rate-limiting
        config:
          minute: 50
          policy: local
EOF

# Replace Gemini API key placeholder
sed -i '' "s|GEMINI_API_KEY_PLACEHOLDER|$GEMINI_API_KEY|g" "$OUTPUT_FILE"

echo -e "${GREEN}✅ Configuration file created: $OUTPUT_FILE${NC}\n"

# Count configuration elements
SERVICES=$(grep -c "^  - name:" "$OUTPUT_FILE" 2>/dev/null || echo "4")
ROUTES=$(grep -c "routes:" "$OUTPUT_FILE" 2>/dev/null || echo "5")
CONSUMERS=$(grep -c "username:" "$OUTPUT_FILE" 2>/dev/null || echo "2")
PLUGINS=$(grep -c "\- name:" "$OUTPUT_FILE" 2>/dev/null || echo "20")

echo -e "${BLUE}Configuration Summary:${NC}"
echo -e "  📦 Services: $SERVICES (Demo API, AI Router, Ollama, Gemini)"
echo -e "  🛣️  Routes: 5"
echo -e "  👥 Consumers: $CONSUMERS (demo-user: 10/min, power-user: 50/min)"
echo -e "  🔌 Plugins: $PLUGINS total"
echo -e "  🤖 AI Providers:"
echo -e "     - Ollama (Mistral) using llama2 provider"
echo -e "     - Google Gemini using gemini provider"
echo -e "  🛡️  Security: key-auth, rate-limiting, ai-prompt-guard, request-size-limiting"

echo -e "\n${YELLOW}Changes from previous version:${NC}"
echo -e "  ❌ Removed ai-semantic-cache (not available in Konnect yet)"
echo -e "  ✅ Changed Ollama provider from 'ollama' to 'llama2' (Konnect compatible)"
echo -e "  ✅ Updated Gemini model to gemini-2.0-flash-exp"

echo -e "\n${CYAN}Next Step: Apply configuration to Konnect${NC}"
echo -e "${BLUE}Run the following command:${NC}\n"
echo -e "  ${GREEN}cd $PROJECT_ROOT${NC}"
echo -e "  ${GREEN}deck gateway sync \\${NC}"
echo -e "  ${GREEN}  --konnect-control-plane-name='$DECK_KONNECT_CONTROL_PLANE_NAME' \\${NC}"
echo -e "  ${GREEN}  --konnect-addr='$KONNECT_CONTROL_PLANE_URL' \\${NC}"
echo -e "  ${GREEN}  --konnect-token=\"\$DECK_KONNECT_TOKEN\" \\${NC}"
echo -e "  ${GREEN}  plugins/06-kong-with-ollama-fixed.yaml${NC}\n"

echo -e "${YELLOW}Or use this one-liner (from scripts directory):${NC}"
echo -e "  ${CYAN}cd $PROJECT_ROOT && deck gateway sync --konnect-control-plane-name=\"\$DECK_KONNECT_CONTROL_PLANE_NAME\" --konnect-addr=\"\$KONNECT_CONTROL_PLANE_URL\" --konnect-token=\"\$DECK_KONNECT_TOKEN\" plugins/06-kong-with-ollama-fixed.yaml${NC}\n"
