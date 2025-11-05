#!/bin/bash

# ==============================================================================
# 05 - Add Authentication & Rate Limiting
# ==============================================================================
# Adds Key Authentication and Rate Limiting to Demo API
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

cd "$(dirname "$0")/.." || exit 1

print_header "STEP 05: ADD AUTHENTICATION & RATE LIMITING"

# Create Kong configuration with auth
cat > plugins/02-kong-with-auth.yaml << 'EOF'
_format_version: "3.0"
_konnect:
  control_plane_name: Kong-Demo

services:
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
        tags:
          - demo

  # AI Router Service
  - name: ai-router-service
    url: http://host.docker.internal:8080
    tags:
      - ai-router
    routes:
      - name: ai-router-route
        paths:
          - /ai
        strip_path: true
        tags:
          - ai

# Consumers
consumers:
  - username: demo-user
    custom_id: user-001
    tags:
      - demo
    keyauth_credentials:
      - key: demo-api-key-12345

  - username: power-user
    custom_id: user-002
    tags:
      - premium
    keyauth_credentials:
      - key: power-key-67890

# Plugins
plugins:
  # Key Authentication for Demo API
  - name: key-auth
    route: demo-api-route
    config:
      key_names:
        - apikey
      hide_credentials: true

  # Key Authentication for AI Router
  - name: key-auth
    route: ai-router-route
    config:
      key_names:
        - apikey
      hide_credentials: true

  # Rate Limiting for demo-user
  - name: rate-limiting
    consumer: demo-user
    config:
      minute: 10
      hour: 100
      policy: local
      fault_tolerant: true

  # Rate Limiting for power-user
  - name: rate-limiting
    consumer: power-user
    config:
      minute: 50
      hour: 500
      policy: local
      fault_tolerant: true

  # Correlation ID
  - name: correlation-id
    config:
      header_name: X-Request-ID
      generator: uuid
      echo_downstream: true
EOF

echo -e "${BLUE}Configuration created: plugins/02-kong-with-auth.yaml${NC}\n"

echo -e "\n${YELLOW}To apply this configuration, run:${NC}"
echo -e "${GREEN}deck gateway sync \\"
echo -e "  --konnect-control-plane-name='Kong-Demo' \\"
echo -e "  --konnect-addr='https://in.api.konghq.com' \\"
echo -e "  --konnect-token='YOUR_TOKEN' \\"
echo -e "  ../plugins/02-kong-with-auth.yaml${NC}"

echo -e "\n${BLUE}Configuration Summary:${NC}"
echo -e "  ✅ Key Authentication enabled for both services"
echo -e "  ✅ Rate Limiting: demo-user (10/min), power-user (50/min)"
echo -e "  ✅ Correlation ID for request tracking"
echo -e "\n${BLUE}Consumers:${NC}"
echo -e "  • demo-user (apikey: demo-api-key-12345)"
echo -e "  • power-user (apikey: power-key-67890)"

echo -e "\n${BLUE}After applying, run: ${YELLOW}./06-test-authentication.sh${NC}"
