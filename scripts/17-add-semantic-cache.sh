#!/bin/bash

# ==============================================================================
# 12 - Add Semantic Cache Plugin
# ==============================================================================
# Adds AI Semantic Cache plugin to AI routes using Redis
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

print_header "STEP 12: ADD AI SEMANTIC CACHE"

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
    echo -e "${GREEN}✅ Environment loaded${NC}"
else
    echo -e "${RED}❌ .env file not found${NC}"
    exit 1
fi

# Check Redis connectivity first
echo -e "\n${BLUE}Checking Redis connectivity...${NC}"
REDIS_URL="redis://${REDIS_USERNAME}:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/${REDIS_DATABASE}"
if redis-cli -u "$REDIS_URL" PING &> /dev/null; then
    echo -e "${GREEN}✅ Redis is accessible${NC}"
else
    echo -e "${RED}❌ Cannot connect to Redis${NC}"
    echo -e "${YELLOW}Run ./11-test-redis.sh first${NC}"
    exit 1
fi

# Generate Kong configuration with semantic cache
OUTPUT_FILE="$PROJECT_ROOT/plugins/05-kong-with-semantic-cache.yaml"

echo -e "\n${BLUE}Generating Kong configuration with Semantic Cache...${NC}"

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

  # Kong Native AI - Ollama Service
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
                provider: "ollama"
                name: "mistral"
                options:
                  max_tokens: 512
                  temperature: 0.7
                  upstream_url: "http://host.docker.internal:11434/v1/chat/completions"
                  llama2_format: "openai"
          - name: ai-semantic-cache
            config:
              vectordb:
                strategy: "redis"
                redis:
                  host: "${REDIS_HOST}"
                  port: ${REDIS_PORT}
                  username: "${REDIS_USERNAME}"
                  password: "${REDIS_PASSWORD}"
                  database: ${REDIS_DATABASE}
                  ssl: true
                  ssl_verify: false
              embeddings:
                auth:
                  header_name: "x-goog-api-key"
                  header_value: "${GEMINI_API_KEY}"
                dimensions: 768
                model: "embedding-001"
                provider: "gemini"
              cache_ttl: 3600
              namespace: "kong_ai_cache_ollama"
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
                header_value: "${GEMINI_API_KEY}"
              logging:
                log_statistics: true
                log_payloads: false
              model:
                provider: "gemini"
                name: "gemini-2.5-flash"
                options:
                  max_tokens: 512
                  temperature: 0.7
                  upstream_url: "https://generativelanguage.googleapis.com/v1beta/chat/completions"
                  llama2_format: "openai"
          - name: ai-semantic-cache
            config:
              vectordb:
                strategy: "redis"
                redis:
                  host: "${REDIS_HOST}"
                  port: ${REDIS_PORT}
                  username: "${REDIS_USERNAME}"
                  password: "${REDIS_PASSWORD}"
                  database: ${REDIS_DATABASE}
                  ssl: true
                  ssl_verify: false
              embeddings:
                auth:
                  header_name: "x-goog-api-key"
                  header_value: "${GEMINI_API_KEY}"
                dimensions: 768
                model: "embedding-001"
                provider: "gemini"
              cache_ttl: 3600
              namespace: "kong_ai_cache_gemini"
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

echo -e "${GREEN}✅ Configuration file created: $OUTPUT_FILE${NC}"

# Replace environment variables in the config
echo -e "\n${BLUE}Replacing environment variables...${NC}"
TEMP_FILE="/tmp/kong-with-cache-expanded.yaml"
envsubst < "$OUTPUT_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$OUTPUT_FILE"
echo -e "${GREEN}✅ Environment variables replaced${NC}"

# Show summary
echo -e "\n${MAGENTA}📊 Configuration Summary:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}New Features Added:${NC}"
echo -e "  ✅ ${GREEN}ai-semantic-cache${NC} plugin on Ollama route"
echo -e "  ✅ ${GREEN}ai-semantic-cache${NC} plugin on Gemini route"
echo -e "  📦 ${CYAN}Cache Storage:${NC} Redis (${REDIS_HOST})"
echo -e "  🔑 ${CYAN}Cache TTL:${NC} 3600 seconds (1 hour)"
echo -e "  🎯 ${CYAN}Embeddings:${NC} Gemini embedding-001 (768 dimensions)"
echo -e "  📝 ${CYAN}Namespaces:${NC}"
echo -e "     - kong_ai_cache_ollama (for Ollama responses)"
echo -e "     - kong_ai_cache_gemini (for Gemini responses)"

echo -e "\n${CYAN}Total Configuration:${NC}"
echo -e "  Services: ${GREEN}4${NC} (Demo API, AI Router, Ollama, Gemini)"
echo -e "  Routes: ${GREEN}6${NC} (Demo, Health, Custom AI, Ollama Chat, Gemini Chat)"
echo -e "  Consumers: ${GREEN}2${NC} (demo-user, power-user)"
echo -e "  Plugins: ${GREEN}18${NC} (including 2 new semantic-cache)"

echo -e "\n${YELLOW}📁 Generated file:${NC}"
echo -e "  ${CYAN}$OUTPUT_FILE${NC}"

echo -e "\n${BLUE}Next Steps:${NC}"
echo -e "  1. ${YELLOW}Review the configuration file${NC}"
echo -e "  2. ${YELLOW}Apply to Kong Konnect:${NC}"
echo -e "     ${CYAN}deck gateway sync \\${NC}"
echo -e "       ${CYAN}--konnect-control-plane-name='Kong-Demo' \\${NC}"
echo -e "       ${CYAN}--konnect-addr='https://in.api.konghq.com' \\${NC}"
echo -e "       ${CYAN}--konnect-token='\$DECK_KONNECT_TOKEN' \\${NC}"
echo -e "       ${CYAN}$OUTPUT_FILE${NC}"
echo -e "  3. ${YELLOW}Test semantic cache: ./13-test-semantic-cache.sh${NC}"

echo -e "\n${GREEN}✅ Semantic Cache configuration ready!${NC}"
