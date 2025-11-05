#!/bin/bash

# ==============================================================================
# 03 - Configure Kong Basic (Services & Routes Only)
# ==============================================================================
# Creates basic services and routes in Kong without authentication
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

print_header "STEP 03: CONFIGURE KONG BASIC ROUTES"

# Create basic Kong configuration
cat > plugins/01-kong-basic.yaml << 'EOF'
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
EOF

echo -e "${BLUE}Configuration created: plugins/01-kong-basic.yaml${NC}\n"
cat plugins/01-kong-basic.yaml

echo -e "\n${YELLOW}To apply this configuration, run:${NC}"
echo -e "${GREEN}deck gateway sync \\"
echo -e "  --konnect-control-plane-name='Kong-Demo' \\"
echo -e "  --konnect-addr='https://in.api.konghq.com' \\"
echo -e "  --konnect-token='YOUR_TOKEN' \\"
echo -e "  ../plugins/01-kong-basic.yaml${NC}"

echo -e "\n${YELLOW}Or apply via Konnect UI:${NC}"
echo -e "  1. Go to Gateway Manager > Services"
echo -e "  2. Create services and routes manually"

echo -e "\n${BLUE}After applying, run: ${YELLOW}./04-test-with-kong.sh${NC}"
