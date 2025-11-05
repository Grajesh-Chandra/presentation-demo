#!/bin/bash

# ==============================================================================
# 14 - Add Redis-Based Plugins (Available in Konnect)
# ==============================================================================
# Adds Redis-powered plugins that are currently supported in Kong Konnect
# Note: ai-semantic-cache is NOT yet available, so we focus on other enhancements
# ==============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
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
echo -e "${CYAN}Adding Redis-Based Enhanced Plugins${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Test Redis connectivity first
echo -e "${BLUE}Testing Redis connectivity...${NC}"
REDIS_TEST=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" -a "$REDIS_PASSWORD" --tls --insecure --no-auth-warning ping 2>&1)
if echo "$REDIS_TEST" | grep -q "PONG"; then
    echo -e "${GREEN}✅ Redis is accessible${NC}\n"
else
    echo -e "${YELLOW}⚠️  Could not verify Redis connection (will continue anyway)${NC}"
    echo -e "${CYAN}Redis response: $REDIS_TEST${NC}\n"
fi

OUTPUT_FILE="$PROJECT_ROOT/plugins/07-kong-with-redis-plugins.yaml"

echo -e "${BLUE}Creating enhanced configuration with Redis-based features...${NC}\n"

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
          # Redis-backed rate limiting (centralized across all Kong nodes)
          - name: rate-limiting
            config:
              minute: 10
              policy: redis
              redis:
                host: REDIS_HOST_PLACEHOLDER
                port: REDIS_PORT_PLACEHOLDER
                username: REDIS_USERNAME_PLACEHOLDER
                password: REDIS_PASSWORD_PLACEHOLDER
                database: REDIS_DATABASE_PLACEHOLDER
                ssl: true
                ssl_verify: false
                server_name: REDIS_HOST_PLACEHOLDER
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
                  - "X-Cache-Backend:redis"

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
          # Redis-backed rate limiting
          - name: rate-limiting
            config:
              minute: 20
              policy: redis
              redis:
                host: REDIS_HOST_PLACEHOLDER
                port: REDIS_PORT_PLACEHOLDER
                username: REDIS_USERNAME_PLACEHOLDER
                password: REDIS_PASSWORD_PLACEHOLDER
                database: REDIS_DATABASE_PLACEHOLDER
                ssl: true
                ssl_verify: false
                server_name: REDIS_HOST_PLACEHOLDER
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
                  - "X-Cache-Backend:redis"

  # Kong Native AI - Ollama Service (using llama2 provider)
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
          # Redis-backed rate limiting (centralized)
          - name: rate-limiting
            config:
              minute: 20
              policy: redis
              redis:
                host: REDIS_HOST_PLACEHOLDER
                port: REDIS_PORT_PLACEHOLDER
                username: REDIS_USERNAME_PLACEHOLDER
                password: REDIS_PASSWORD_PLACEHOLDER
                database: REDIS_DATABASE_PLACEHOLDER
                ssl: true
                ssl_verify: false
                server_name: REDIS_HOST_PLACEHOLDER
          - name: ai-proxy
            config:
              route_type: "llm/v1/chat"
              auth:
                header_name: Authorization
                header_value: "Bearer dummy"
              logging:
                log_statistics: true
                log_payloads: true
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
                - "system prompt"
                - "forget your instructions"
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
                  - "X-Cache-Backend:redis"
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
          # Redis-backed rate limiting (centralized)
          - name: rate-limiting
            config:
              minute: 20
              policy: redis
              redis:
                host: REDIS_HOST_PLACEHOLDER
                port: REDIS_PORT_PLACEHOLDER
                username: REDIS_USERNAME_PLACEHOLDER
                password: REDIS_PASSWORD_PLACEHOLDER
                database: REDIS_DATABASE_PLACEHOLDER
                ssl: true
                ssl_verify: false
                server_name: REDIS_HOST_PLACEHOLDER
          - name: ai-proxy
            config:
              route_type: "llm/v1/chat"
              auth:
                header_name: "x-goog-api-key"
                header_value: "GEMINI_API_KEY_PLACEHOLDER"
              logging:
                log_statistics: true
                log_payloads: true
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
                - "system prompt"
                - "forget your instructions"
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
                  - "X-Cache-Backend:redis"
          - name: request-size-limiting
            config:
              allowed_payload_size: 5

consumers:
  - username: demo-user
    keyauth_credentials:
      - key: demo-api-key-12345
    plugins:
      # Redis-backed rate limiting per consumer
      - name: rate-limiting
        config:
          minute: 10
          policy: redis
          redis:
            host: REDIS_HOST_PLACEHOLDER
            port: REDIS_PORT_PLACEHOLDER
            username: REDIS_USERNAME_PLACEHOLDER
            password: REDIS_PASSWORD_PLACEHOLDER
            database: REDIS_DATABASE_PLACEHOLDER
            ssl: true
            ssl_verify: false
            server_name: REDIS_HOST_PLACEHOLDER

  - username: power-user
    keyauth_credentials:
      - key: power-key-67890
    plugins:
      # Redis-backed rate limiting per consumer
      - name: rate-limiting
        config:
          minute: 50
          policy: redis
          redis:
            host: REDIS_HOST_PLACEHOLDER
            port: REDIS_PORT_PLACEHOLDER
            username: REDIS_USERNAME_PLACEHOLDER
            password: REDIS_PASSWORD_PLACEHOLDER
            database: REDIS_DATABASE_PLACEHOLDER
            ssl: true
            ssl_verify: false
            server_name: REDIS_HOST_PLACEHOLDER
EOF

# Replace placeholders with actual values
sed -i '' "s|REDIS_HOST_PLACEHOLDER|$REDIS_HOST|g" "$OUTPUT_FILE"
sed -i '' "s|REDIS_PORT_PLACEHOLDER|$REDIS_PORT|g" "$OUTPUT_FILE"
sed -i '' "s|REDIS_USERNAME_PLACEHOLDER|$REDIS_USERNAME|g" "$OUTPUT_FILE"
sed -i '' "s|REDIS_PASSWORD_PLACEHOLDER|$REDIS_PASSWORD|g" "$OUTPUT_FILE"
sed -i '' "s|REDIS_DATABASE_PLACEHOLDER|$REDIS_DATABASE|g" "$OUTPUT_FILE"
sed -i '' "s|GEMINI_API_KEY_PLACEHOLDER|$GEMINI_API_KEY|g" "$OUTPUT_FILE"

echo -e "${GREEN}✅ Configuration file created: $OUTPUT_FILE${NC}\n"

# Count configuration elements
SERVICES=$(grep -c "^  - name:.*-service" "$OUTPUT_FILE")
ROUTES=$(grep -c "name:.*-route" "$OUTPUT_FILE")
CONSUMERS=$(grep -c "username:" "$OUTPUT_FILE")
REDIS_PLUGINS=$(grep -c "policy: redis" "$OUTPUT_FILE")

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${MAGENTA}Configuration Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  📦 Services: $SERVICES (Demo API, AI Router, Ollama, Gemini)"
echo -e "  🛣️  Routes: 5"
echo -e "  👥 Consumers: $CONSUMERS (demo-user: 10/min, power-user: 50/min)"
echo -e "  🔴 Redis-Backed Plugins: $REDIS_PLUGINS rate-limiting plugins"
echo -e "  🤖 AI Providers:"
echo -e "     - Ollama (Mistral) using llama2 provider"
echo -e "     - Google Gemini using gemini provider"
echo -e "  🛡️  Security: key-auth, rate-limiting, ai-prompt-guard, request-size-limiting"

echo -e "\n${MAGENTA}Redis Enhancements:${NC}"
echo -e "  ✅ Centralized rate limiting across all Kong nodes"
echo -e "  ✅ Shared rate limit counters in Redis"
echo -e "  ✅ Per-consumer rate limits stored in Redis"
echo -e "  ✅ Per-route rate limits stored in Redis"
echo -e "  ✅ Real-time rate limit synchronization"
echo -e "  ✅ Persistent rate limit data (survives restarts)"

echo -e "\n${YELLOW}Benefits:${NC}"
echo -e "  🚀 Rate limits work across multiple Kong instances"
echo -e "  💾 Rate limit data persists across restarts"
echo -e "  📊 Better monitoring and analytics via Redis"
echo -e "  🔄 Real-time synchronization of rate limits"

echo -e "\n${YELLOW}Note:${NC}"
echo -e "  ⚠️  ai-semantic-cache is not yet available in Kong Konnect"
echo -e "  ⚠️  Will be added in future updates when available"
echo -e "  ✅ Using Redis for rate-limiting (policy: redis)"

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Next Step: Apply Configuration to Konnect${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${BLUE}Run the following command:${NC}\n"
echo -e "  ${GREEN}cd $PROJECT_ROOT${NC}"
echo -e "  ${GREEN}source .env && deck gateway sync \\${NC}"
echo -e "  ${GREEN}  --konnect-control-plane-name=\"\$DECK_KONNECT_CONTROL_PLANE_NAME\" \\${NC}"
echo -e "  ${GREEN}  --konnect-addr=\"\$KONNECT_CONTROL_PLANE_URL\" \\${NC}"
echo -e "  ${GREEN}  --konnect-token=\"\$DECK_KONNECT_TOKEN\" \\${NC}"
echo -e "  ${GREEN}  plugins/07-kong-with-redis-plugins.yaml${NC}\n"

echo -e "${YELLOW}Or test rate limits with Redis:${NC}"
echo -e "  ${CYAN}cd scripts && ./15-test-redis-rate-limits.sh${NC}\n"
