#!/bin/bash

# ==============================================================================
# Publish API to Kong Dev Portal
# ==============================================================================
# This script automates the complete process of publishing an API to Kong Dev Portal:
# 1. Register API in Konnect catalog
# 2. Upload OpenAPI specification
# 3. Link to Gateway Service
# 4. Publish to Dev Portal
# 5. Apply authentication strategy (key-auth)
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables
source "$(dirname "$0")/load-env.sh"

# Configuration
API_ENDPOINT="${KONNECT_CONTROL_PLANE_URL}/v3"
API_NAME="${API_NAME:-Demo API}"
API_DESCRIPTION="${API_DESCRIPTION:-Sample Node.js REST API with user management and product catalog}"
API_VERSION="${API_VERSION:-1.0.0}"
API_SERVICE_NAME="${API_SERVICE_NAME:-demo-api-service}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Publishing ${API_NAME} to Kong Dev Portal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ==============================================================================
# Step 0: Check if API already exists
# ==============================================================================
echo -e "${BLUE}🔍 Step 0: Checking if API already exists...${NC}"

EXISTING_API=$(curl -s "${API_ENDPOINT}/apis" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  | jq -r '.data[] | select(.name=="'"${API_NAME}"'" and .version=="'"${API_VERSION}"'") | .id')

if [ -n "$EXISTING_API" ] && [ "$EXISTING_API" != "null" ]; then
  echo -e "${YELLOW}⚠️  API '${API_NAME}' v${API_VERSION} already exists (ID: ${EXISTING_API})${NC}"
  echo -e "${YELLOW}🗑️  Deleting existing API...${NC}"

  DELETE_RESPONSE=$(curl -s -X DELETE "${API_ENDPOINT}/apis/${EXISTING_API}" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}")

  echo -e "${GREEN}✅ Existing API deleted${NC}"
  sleep 1
else
  echo -e "${GREEN}✅ No existing API found, proceeding with registration${NC}"
fi

# ==============================================================================
# Step 1: Register API in Catalog
# ==============================================================================
echo ""
echo -e "${BLUE}📝 Step 1: Registering API in catalog...${NC}"

RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/apis" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'"${API_NAME}"'",
    "description": "'"${API_DESCRIPTION}"'",
    "version": "'"${API_VERSION}"'",
    "attributes": {
      "env": ["development"],
      "domains": ["web", "mobile"],
      "team": ["platform-team"]
    }
  }')

# Extract API ID
API_ID=$(echo "$RESPONSE" | jq -r '.id')
if [ "$API_ID" = "null" ] || [ -z "$API_ID" ]; then
  echo -e "${RED}❌ Failed to create API${NC}"
  echo "$RESPONSE" | jq '.'
  exit 1
fi
echo -e "${GREEN}✅ API registered with ID: ${API_ID}${NC}"

# ==============================================================================
# Step 2: Create OpenAPI Specification
# ==============================================================================
echo ""
echo -e "${BLUE}📤 Step 2: Creating OpenAPI specification...${NC}"

# Create OpenAPI spec dynamically
cat > /tmp/demo-api-openapi.yaml << 'EOF'
openapi: 3.0.3
info:
  title: Demo API
  version: 1.0.0
  description: |
    Sample Node.js REST API with user management and product catalog.
    Provides CRUD operations for users and products with authentication.

servers:
  - url: http://localhost:8000/api/demo
    description: Development server via Kong Gateway

components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: apikey
      description: |
        API key for authentication. Obtain from Kong Dev Portal:
        1. Sign up for Dev Portal
        2. Create an application
        3. Register application with this API
        4. Copy the generated API key

  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
          example: 1
        name:
          type: string
          example: John Doe
        email:
          type: string
          format: email
          example: john@example.com
        createdAt:
          type: string
          format: date-time

    Product:
      type: object
      properties:
        id:
          type: integer
          example: 1
        name:
          type: string
          example: Laptop
        price:
          type: number
          format: float
          example: 999.99
        category:
          type: string
          example: Electronics

security:
  - ApiKeyAuth: []

paths:
  /api/v1/health:
    get:
      summary: Health check
      description: Check if the API is healthy and running
      security: []
      responses:
        '200':
          description: API is healthy
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: healthy
                  timestamp:
                    type: string
                    format: date-time

  /api/v1/users:
    get:
      summary: List all users
      description: Returns a list of all users in the system
      security:
        - ApiKeyAuth: []
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
        '401':
          description: Unauthorized - missing or invalid API key

    post:
      summary: Create a new user
      description: Create a new user in the system
      security:
        - ApiKeyAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                name:
                  type: string
                  example: Jane Smith
                email:
                  type: string
                  format: email
                  example: jane@example.com
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Bad request - invalid input
        '401':
          description: Unauthorized - missing or invalid API key

  /api/v1/users/{id}:
    get:
      summary: Get user by ID
      description: Returns a specific user by ID
      security:
        - ApiKeyAuth: []
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
          description: User ID
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          description: User not found
        '401':
          description: Unauthorized - missing or invalid API key

  /api/v1/products:
    get:
      summary: List all products
      description: Returns a list of all products in the catalog
      security:
        - ApiKeyAuth: []
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Product'
        '401':
          description: Unauthorized - missing or invalid API key

  /api/v1/stats:
    get:
      summary: Get API statistics
      description: Returns usage statistics for the API
      security:
        - ApiKeyAuth: []
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  totalUsers:
                    type: integer
                    example: 150
                  totalProducts:
                    type: integer
                    example: 42
                  apiVersion:
                    type: string
                    example: 1.0.0
        '401':
          description: Unauthorized - missing or invalid API key
EOF

# Upload specification
SPEC_CONTENT=$(cat /tmp/demo-api-openapi.yaml | jq -Rs .)
RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/apis/${API_ID}/specifications" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": '"${SPEC_CONTENT}"'
  }')

SPEC_ID=$(echo "$RESPONSE" | jq -r '.id')
if [ "$SPEC_ID" = "null" ] || [ -z "$SPEC_ID" ]; then
  echo -e "${RED}❌ Failed to upload specification${NC}"
  echo "$RESPONSE" | jq '.'
  exit 1
fi
echo -e "${GREEN}✅ Specification uploaded with ID: ${SPEC_ID}${NC}"

# ==============================================================================
# Step 3: Get Control Plane ID and Service ID
# ==============================================================================
echo ""
echo -e "${BLUE}🔍 Step 3: Finding Gateway Service...${NC}"

# Use Control Plane ID from .env
CONTROL_PLANE_ID="${DECK_KONNECT_CONTROL_PLANE_ID}"

if [ -z "$CONTROL_PLANE_ID" ]; then
  echo -e "${RED}❌ DECK_KONNECT_CONTROL_PLANE_ID not set in .env${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Control Plane ID: ${CONTROL_PLANE_ID}${NC}"

# Get Service ID from Konnect API (deck dump doesn't include IDs)
echo -e "${BLUE}Fetching service ID from Konnect API...${NC}"
SERVICE_ID=$(curl -s "${KONNECT_CONTROL_PLANE_URL}/v2/control-planes/${CONTROL_PLANE_ID}/core-entities/services" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  | jq -r '.data[] | select(.name=="'"${API_SERVICE_NAME}"'") | .id')

if [ -z "$SERVICE_ID" ] || [ "$SERVICE_ID" = "null" ]; then
  echo -e "${RED}❌ Failed to find service: ${API_SERVICE_NAME}${NC}"
  echo -e "${YELLOW}Available services:${NC}"
  curl -s "${KONNECT_CONTROL_PLANE_URL}/v2/control-planes/${CONTROL_PLANE_ID}/core-entities/services" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
    | jq -r '.data[]? | "  - \(.name) (ID: \(.id))"'
  exit 1
fi
echo -e "${GREEN}✅ Service ID: ${SERVICE_ID}${NC}"

# ==============================================================================
# Step 4: Link API to Gateway Service
# ==============================================================================
echo ""
echo -e "${BLUE}🔗 Step 4: Linking API to Gateway Service...${NC}"

RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/apis/${API_ID}/implementations" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "control_plane_id": "'"${CONTROL_PLANE_ID}"'",
      "id": "'"${SERVICE_ID}"'"
    }
  }')

IMPL_ID=$(echo "$RESPONSE" | jq -r '.id')
if [ "$IMPL_ID" = "null" ] || [ -z "$IMPL_ID" ]; then
  echo -e "${RED}❌ Failed to link to Gateway Service${NC}"
  echo "$RESPONSE" | jq '.'
  exit 1
fi
echo -e "${GREEN}✅ API linked to Gateway Service${NC}"

# ==============================================================================
# Step 5: Get or Create Portal ID
# ==============================================================================
echo ""
echo -e "${BLUE}🌐 Step 5: Finding or creating Dev Portal...${NC}"

PORTAL_ID=$(curl -s "${API_ENDPOINT}/portals" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  | jq -r '.data[0].id')

if [ "$PORTAL_ID" = "null" ] || [ -z "$PORTAL_ID" ]; then
  echo -e "${YELLOW}⚠️  No Dev Portal found, creating one...${NC}"

  # Create a new portal
  PORTAL_RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/portals" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Developer Portal",
      "auto_approve_applications": true
    }')

  PORTAL_ID=$(echo "$PORTAL_RESPONSE" | jq -r '.id')

  if [ "$PORTAL_ID" = "null" ] || [ -z "$PORTAL_ID" ]; then
    echo -e "${RED}❌ Failed to create Dev Portal${NC}"
    echo "$PORTAL_RESPONSE" | jq '.'
    exit 1
  fi
  echo -e "${GREEN}✅ Dev Portal created with ID: ${PORTAL_ID}${NC}"
else
  echo -e "${GREEN}✅ Portal ID: ${PORTAL_ID}${NC}"
fi

# ==============================================================================
# Step 6: Publish API to Dev Portal
# ==============================================================================
echo ""
echo -e "${BLUE}🚀 Step 6: Publishing to Dev Portal...${NC}"

RESPONSE=$(curl -s -X PUT "${API_ENDPOINT}/apis/${API_ID}/publications/${PORTAL_ID}" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "visibility": "public"
  }')

PUB_ID=$(echo "$RESPONSE" | jq -r '.id // empty')
if [ -z "$PUB_ID" ]; then
  echo -e "${YELLOW}⚠️  Publication response: ${NC}"
  echo "$RESPONSE" | jq '.'
fi
echo -e "${GREEN}✅ API published to Dev Portal${NC}"

# ==============================================================================
# Step 7: Apply Authentication Strategy
# ==============================================================================
echo ""
echo -e "${BLUE}🔐 Step 7: Applying authentication strategy...${NC}"

AUTH_STRATEGIES=$(curl -s "${API_ENDPOINT}/portal-auth-strategies" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}")

AUTH_STRATEGY_ID=$(echo "$AUTH_STRATEGIES" | jq -r '.data[]? | select(.name=="key-auth") | .id' 2>/dev/null)

if [ -n "$AUTH_STRATEGY_ID" ] && [ "$AUTH_STRATEGY_ID" != "null" ]; then
  RESPONSE=$(curl -s -X PATCH "${API_ENDPOINT}/apis/${API_ID}/publications/${PORTAL_ID}" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "auth_strategy_ids": ["'"${AUTH_STRATEGY_ID}"'"]
    }')
  echo -e "${GREEN}✅ Authentication strategy applied (key-auth)${NC}"
else
  echo -e "${YELLOW}⚠️  No key-auth strategy found, skipping...${NC}"
  echo -e "${YELLOW}   You can configure authentication later in the Konnect Portal settings${NC}"
fi

# ==============================================================================
# Summary
# ==============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ API Publishing Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo "  • API Name: ${API_NAME}"
echo "  • API ID: ${API_ID}"
echo "  • Specification ID: ${SPEC_ID}"
echo "  • Portal ID: ${PORTAL_ID}"
echo "  • Status: Published"
echo ""
echo -e "${YELLOW}🌐 Next Steps:${NC}"
echo "  1. Visit Dev Portal to verify publication"
echo "  2. Sign up as a developer (if not already)"
echo "  3. Create an application in the Portal"
echo "  4. Register your app with '${API_NAME}'"
echo "  5. Copy the Portal-generated API key (starts with 'kpat_')"
echo "  6. Run test script: ./19-test-portal-api.sh"
echo ""
echo -e "${YELLOW}📝 Important:${NC}"
echo "  • Portal keys start with 'kpat_' prefix"
echo "  • Consumer keys (demo-api-key-*) won't work with Portal apps"
echo "  • You must use Portal-generated keys for testing"
echo ""

# Save API ID for test script
echo "$API_ID" > /tmp/portal-api-id.txt
echo -e "${GREEN}💾 API ID saved to /tmp/portal-api-id.txt${NC}"
