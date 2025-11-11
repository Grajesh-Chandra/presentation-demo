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

  # Enable developer registration
  echo -e "${BLUE}Configuring portal for developer self-registration...${NC}"
  PORTAL_CONFIG=$(curl -s -X PATCH "${API_ENDPOINT}/portals/${PORTAL_ID}" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "auto_approve_applications": true,
      "auto_approve_developers": true
    }')
  echo -e "${GREEN}✅ Portal configured for self-registration${NC}"
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
# Step 7: Create Landing Page Content
# ==============================================================================
echo ""
echo -e "${BLUE}📄 Step 7: Creating portal landing page...${NC}"

# Create the landing page content file
cat > /tmp/portal-landing-page.md <<'PAGEEOF'
---
title: Welcome to Demo API Platform
description: Everything you need to integrate powerful APIs into your applications
---

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #003F6C 0%, #00588A 100%);
  padding: clamp(60px, 8vw, 100px) 0;
  margin-top: -20px;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(32px, 6vw, 56px)"
  title-tag: "h1"
  text-align: "center"
  title-line-height: "clamp(40px, 7vw, 64px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(18px, 3vw, 24px)"
  description-line-height: "clamp(28px, 4vw, 36px)"
  styles: |
    h1 {
      color: #FFFFFF;
      margin-bottom: 20px;
    }
    p {
      color: rgba(255, 255, 255, 0.9);
      max-width: 800px;
      margin: 0 auto 40px;
    }
  ---
  #title
  Welcome to Demo API Platform

  #description
  Everything you need to integrate powerful APIs into your applications. Get started in minutes with our comprehensive documentation and examples.

  #actions
    ::button
    ---
    appearance: "primary"
    size: "large"
    styles: |
      background-color: #00C9B7;
      color: #003F6C;
      font-weight: 600;
      padding: 16px 32px;
      border-radius: 8px;
      font-size: 18px;
      border: none;
      box-shadow: 0 4px 12px rgba(0, 201, 183, 0.3);
      transition: all 0.3s ease;
      cursor: pointer;
      &:hover {
        background-color: #00E5CD;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 201, 183, 0.4);
      }
    ---
    Get Started
    ::
  ::
::

::page-section
---
full-width: true
styles: |
  background: #F9FAFB;
  padding: clamp(60px, 8vw, 80px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 40px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 48px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 700px;
      margin: 0 auto 60px;
    }
  ---
  #title
  Quick Start Guides

  #description
  Get up and running quickly with our step-by-step guides
  ::

  ::grid-layout
  ---
  columns: 2
  gap: 48px
  columns-breakpoints:
    mobile: 1
    desktop: 2
    laptop: 2
    phablet: 1
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  ---
    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin: 0;
      }
    ---
    #title
    🚀 Getting Started

    #description
    Create your first application and get your API key in minutes. Follow our step-by-step guide to make your first API call.
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin: 0;
      }
    ---
    #title
    📚 API Documentation

    #description
    Explore our complete API reference with interactive examples. Test endpoints directly in your browser with live API calls.
    ::
  ::
::

::page-section
---
full-width: true
styles: |
  background: #FFFFFF;
  padding: clamp(60px, 8vw, 80px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 40px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 48px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 700px;
      margin: 0 auto 60px;
    }
  ---
  #title
  Featured APIs

  #description
  Start building with our most popular APIs
  ::

  ::grid-layout
  ---
  columns: 3
  gap: 32px
  columns-breakpoints:
    mobile: 1
    desktop: 3
    laptop: 3
    phablet: 1
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  ---
    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(20px, 4vw, 24px)"
    title-tag: "h4"
    text-align: "left"
    title-line-height: "clamp(28px, 5vw, 32px)"
    title-font-weight: "600"
    description-font-weight: "400"
    description-font-size: "clamp(14px, 3vw, 15px)"
    description-line-height: "clamp(22px, 4vw, 24px)"
    styles: |
      background: #FFFFFF;
      border: 1px solid #E5E7EB;
      border-radius: 10px;
      padding: 28px;
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        border-color: #00C9B7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 201, 183, 0.15);
      }
      h4 {
        color: #1F2937;
        margin-bottom: 8px;
      }
      p {
        color: #6B7280;
        margin-bottom: 16px;
      }
    ---
    #title
    📊 Demo API

    #description
    REST API for user and product management with full CRUD operations.
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(20px, 4vw, 24px)"
    title-tag: "h4"
    text-align: "left"
    title-line-height: "clamp(28px, 5vw, 32px)"
    title-font-weight: "600"
    description-font-weight: "400"
    description-font-size: "clamp(14px, 3vw, 15px)"
    description-line-height: "clamp(22px, 4vw, 24px)"
    styles: |
      background: #FFFFFF;
      border: 1px solid #E5E7EB;
      border-radius: 10px;
      padding: 28px;
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        border-color: #00C9B7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 201, 183, 0.15);
      }
      h4 {
        color: #1F2937;
        margin-bottom: 8px;
      }
      p {
        color: #6B7280;
        margin-bottom: 16px;
      }
    ---
    #title
    🤖 AI Router

    #description
    AI gateway for routing requests to multiple LLM providers with unified API.
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(20px, 4vw, 24px)"
    title-tag: "h4"
    text-align: "left"
    title-line-height: "clamp(28px, 5vw, 32px)"
    title-font-weight: "600"
    description-font-weight: "400"
    description-font-size: "clamp(14px, 3vw, 15px)"
    description-line-height: "clamp(22px, 4vw, 24px)"
    styles: |
      background: #FFFFFF;
      border: 1px solid #E5E7EB;
      border-radius: 10px;
      padding: 28px;
      transition: all 0.3s ease;
      height: 100%;
      &:hover {
        border-color: #00C9B7;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 201, 183, 0.15);
      }
      h4 {
        color: #1F2937;
        margin-bottom: 8px;
      }
      p {
        color: #6B7280;
        margin-bottom: 16px;
      }
    ---
    #title
    📈 Analytics API

    #description
    Real-time analytics and metrics for monitoring API usage and performance.
    ::
  ::
::

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #F9FAFB 0%, #E5E7EB 100%);
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 36px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 44px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h2 {
      color: #1F2937;
      margin-bottom: 16px;
    }
    p {
      color: #6B7280;
      max-width: 700px;
      margin: 0 auto 40px;
    }
  ---
  #title
  Ready to Get Started?

  #description
  Create an application below to get your API key and start building

  #actions
    ::button
    ---
    appearance: "primary"
    size: "large"
    styles: |
      background-color: #00C9B7;
      color: #003F6C;
      font-weight: 600;
      padding: 16px 32px;
      border-radius: 8px;
      font-size: 18px;
      border: none;
      box-shadow: 0 4px 12px rgba(0, 201, 183, 0.3);
      transition: all 0.3s ease;
      cursor: pointer;
      &:hover {
        background-color: #00E5CD;
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 201, 183, 0.4);
      }
    ---
    Browse APIs
    ::
  ::
::
PAGEEOF

# Read the page content
PAGE_CONTENT=$(cat /tmp/portal-landing-page.md)

# Check if homepage already exists and delete it
EXISTING_HOMEPAGE=$(curl -s "${API_ENDPOINT}/portals/${PORTAL_ID}/pages" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  | jq -r '.data[] | select(.slug=="/") | .id')

if [ -n "$EXISTING_HOMEPAGE" ] && [ "$EXISTING_HOMEPAGE" != "null" ]; then
  echo -e "${YELLOW}⚠️  Existing homepage found, deleting...${NC}"
  curl -s -X DELETE "${API_ENDPOINT}/portals/${PORTAL_ID}/pages/${EXISTING_HOMEPAGE}" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" > /dev/null
  echo -e "${GREEN}✅ Old homepage deleted${NC}"
fi

# Upload the page to the portal with slug "/" to set it as homepage
PAGE_RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/portals/${PORTAL_ID}/pages" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "/",
    "title": "Welcome to Demo API Platform",
    "description": "Everything you need to integrate powerful APIs into your applications",
    "visibility": "public",
    "content": '"$(echo "$PAGE_CONTENT" | jq -Rs .)"',
    "status": "published"
  }')

PAGE_ID=$(echo "$PAGE_RESPONSE" | jq -r '.id // empty')
if [ -n "$PAGE_ID" ]; then
  echo -e "${GREEN}✅ Homepage created with slug '/' (ID: ${PAGE_ID})${NC}"
else
  echo -e "${YELLOW}⚠️  Could not create homepage automatically${NC}"
  echo "Response: $PAGE_RESPONSE" | jq '.'
  echo -e "${YELLOW}   You can create it manually using the portal guide${NC}"
fi

# ==============================================================================
# Step 8: Create and Apply Authentication Strategy
# ==============================================================================
echo ""
echo -e "${BLUE}🔐 Step 8: Configuring authentication strategy...${NC}"

# Check if key-auth strategy already exists
AUTH_STRATEGIES=$(curl -s "${KONNECT_CONTROL_PLANE_URL}/v2/application-auth-strategies" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}")

AUTH_STRATEGY_ID=$(echo "$AUTH_STRATEGIES" | jq -r '.data[]? | select(.name=="Key Auth" or .name=="key-auth") | .id' 2>/dev/null)

if [ -z "$AUTH_STRATEGY_ID" ] || [ "$AUTH_STRATEGY_ID" = "null" ]; then
  echo -e "${BLUE}Creating key-auth strategy...${NC}"

  # Create key-auth strategy
  STRATEGY_RESPONSE=$(curl -s -X POST "${KONNECT_CONTROL_PLANE_URL}/v2/application-auth-strategies" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Key Auth",
      "display_name": "API Key Authentication",
      "strategy_type": "key_auth",
      "configs": {
        "key-auth": {
          "key_names": [
            "apikey",
            "x-api-key",
            "api-key"
          ]
        }
      }
    }')

  AUTH_STRATEGY_ID=$(echo "$STRATEGY_RESPONSE" | jq -r '.id')

  if [ -n "$AUTH_STRATEGY_ID" ] && [ "$AUTH_STRATEGY_ID" != "null" ]; then
    echo -e "${GREEN}✅ Key-auth strategy created (ID: ${AUTH_STRATEGY_ID})${NC}"
  else
    echo -e "${YELLOW}⚠️  Could not create key-auth strategy${NC}"
    echo "$STRATEGY_RESPONSE" | jq '.'
  fi
else
  echo -e "${GREEN}✅ Key-auth strategy found (ID: ${AUTH_STRATEGY_ID})${NC}"
fi

# Apply strategy to the API publication
if [ -n "$AUTH_STRATEGY_ID" ] && [ "$AUTH_STRATEGY_ID" != "null" ]; then
  echo -e "${BLUE}Applying strategy to API publication...${NC}"

  RESPONSE=$(curl -s -X PATCH "${API_ENDPOINT}/apis/${API_ID}/publications/${PORTAL_ID}" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "auth_strategy_ids": ["'"${AUTH_STRATEGY_ID}"'"]
    }')

  echo -e "${GREEN}✅ Authentication strategy applied to API${NC}"
else
  echo -e "${YELLOW}⚠️  Skipping auth strategy application${NC}"
fi

# ==============================================================================
# Step 9: Create Additional Portal Pages (Documentation and Guides)
# ==============================================================================
echo ""
echo -e "${BLUE}📚 Step 9: Creating additional portal pages...${NC}"

# Create API Documentation Page
cat > /tmp/portal-api-docs.md <<'DOCSEOF'
---
title: API Documentation
description: Complete API reference with examples and best practices
---

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #003F6C 0%, #00588A 100%);
  padding: clamp(50px, 7vw, 80px) 0;
  margin-top: -20px;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 44px)"
  title-tag: "h1"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 52px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h1 {
      color: #FFFFFF;
      margin-bottom: 16px;
    }
    p {
      color: rgba(255, 255, 255, 0.9);
      max-width: 700px;
      margin: 0 auto;
    }
  ---
  #title
  📚 API Documentation

  #description
  Complete reference guide with examples, best practices, and integration patterns
  ::
::

::page-section
---
full-width: true
styles: |
  background: #FFFFFF;
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(24px, 4vw, 32px)"
  title-tag: "h2"
  text-align: "left"
  title-line-height: "clamp(32px, 5vw, 40px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(15px, 3vw, 16px)"
  description-line-height: "clamp(24px, 4vw, 26px)"
  styles: |
    max-width: 900px;
    margin: 0 auto;
    padding: 0 20px;
    h2 {
      color: #1F2937;
      margin-bottom: 20px;
    }
    h3 {
      color: #003F6C;
      margin-top: 32px;
      margin-bottom: 16px;
      font-size: 24px;
    }
    p {
      color: #6B7280;
      margin-bottom: 16px;
    }
    pre {
      background: #1F2937;
      color: #F9FAFB;
      padding: 24px;
      border-radius: 8px;
      overflow-x: auto;
      margin: 24px 0;
      font-family: 'Monaco', 'Menlo', monospace;
      font-size: 14px;
      line-height: 1.6;
    }
    code {
      background: #E5E7EB;
      color: #1F2937;
      padding: 2px 6px;
      border-radius: 4px;
      font-family: 'Monaco', 'Menlo', monospace;
      font-size: 14px;
    }
    ul {
      color: #6B7280;
      margin: 16px 0;
      padding-left: 24px;
    }
    li {
      margin-bottom: 8px;
    }
  ---
  #title
  Getting Started

  #description

  ### Authentication

  All API requests require authentication using an API key. Include your API key in the `apikey` header:

  ```bash
  curl -X GET "https://api.example.com/api/v1/users" \
    -H "apikey: your_api_key_here" \
    -H "Content-Type: application/json"
  ```

  ### Base URL

  All API endpoints are relative to the base URL:

  ```
  https://api.example.com/api/demo
  ```

  ### Response Format

  All responses are returned in JSON format:

  ```json
  {
    "data": { ... },
    "status": "success",
    "timestamp": "2025-01-15T10:30:00Z"
  }
  ```

  ### Error Handling

  The API uses standard HTTP status codes:

  - `200 OK` - Request succeeded
  - `201 Created` - Resource created successfully
  - `400 Bad Request` - Invalid request parameters
  - `401 Unauthorized` - Missing or invalid API key
  - `404 Not Found` - Resource not found
  - `500 Internal Server Error` - Server error

  Error responses include details:

  ```json
  {
    "error": {
      "code": "INVALID_REQUEST",
      "message": "Missing required field: email"
    },
    "status": "error",
    "timestamp": "2025-01-15T10:30:00Z"
  }
  ```

  ### Rate Limiting

  API requests are rate limited to protect service availability:

  - **Rate Limit**: 100 requests per minute
  - **Burst Limit**: 20 requests per second

  Rate limit headers are included in responses:

  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 95
  X-RateLimit-Reset: 1642252800
  ```

  ### Pagination

  List endpoints support pagination using query parameters:

  ```bash
  GET /api/v1/users?page=1&limit=20
  ```

  Response includes pagination metadata:

  ```json
  {
    "data": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "pages": 8
    }
  }
  ```
  ::
::

::page-section
---
full-width: true
styles: |
  background: #F9FAFB;
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(24px, 4vw, 32px)"
  title-tag: "h2"
  text-align: "center"
  title-line-height: "clamp(32px, 5vw, 40px)"
  title-font-weight: "700"
  styles: |
    max-width: 900px;
    margin: 0 auto;
    padding: 0 20px;
    h2 {
      color: #1F2937;
      margin-bottom: 40px;
    }
  ---
  #title
  Browse API Specifications

  #description
  ::apis-list
  ---
  persist-page-number: true
  cta-text: "View API Details"
  ---
  ::
  ::
::
DOCSEOF

DOCS_CONTENT=$(cat /tmp/portal-api-docs.md)

# Check if documentation page exists and delete it
EXISTING_DOCS=$(curl -s "${API_ENDPOINT}/portals/${PORTAL_ID}/pages" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  | jq -r '.data[] | select(.slug=="/documentation") | .id')

if [ -n "$EXISTING_DOCS" ] && [ "$EXISTING_DOCS" != "null" ]; then
  curl -s -X DELETE "${API_ENDPOINT}/portals/${PORTAL_ID}/pages/${EXISTING_DOCS}" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" > /dev/null
fi

# Create documentation page
DOCS_RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/portals/${PORTAL_ID}/pages" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "/documentation",
    "title": "API Documentation",
    "description": "Complete API reference with examples and best practices",
    "visibility": "public",
    "content": '"$(echo "$DOCS_CONTENT" | jq -Rs .)"',
    "status": "published"
  }')

DOCS_ID=$(echo "$DOCS_RESPONSE" | jq -r '.id // empty')
if [ -n "$DOCS_ID" ]; then
  echo -e "${GREEN}✅ Documentation page created (ID: ${DOCS_ID})${NC}"
else
  echo -e "${YELLOW}⚠️  Could not create documentation page${NC}"
fi

# Create Guides Page
cat > /tmp/portal-guides.md <<'GUIDESEOF'
---
title: Developer Guides
description: Step-by-step guides to help you integrate and use our APIs effectively
---

::page-section
---
full-width: true
styles: |
  background: linear-gradient(135deg, #003F6C 0%, #00588A 100%);
  padding: clamp(50px, 7vw, 80px) 0;
  margin-top: -20px;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(28px, 5vw, 44px)"
  title-tag: "h1"
  text-align: "center"
  title-line-height: "clamp(36px, 6vw, 52px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(16px, 3vw, 20px)"
  description-line-height: "clamp(24px, 4vw, 30px)"
  styles: |
    h1 {
      color: #FFFFFF;
      margin-bottom: 16px;
    }
    p {
      color: rgba(255, 255, 255, 0.9);
      max-width: 700px;
      margin: 0 auto;
    }
  ---
  #title
  📖 Developer Guides

  #description
  Step-by-step guides to help you integrate and use our APIs effectively
  ::
::

::page-section
---
full-width: true
styles: |
  background: #F9FAFB;
  padding: clamp(60px, 8vw, 80px) 0;
---
  ::grid-layout
  ---
  columns: 2
  gap: 32px
  columns-breakpoints:
    mobile: 1
    desktop: 2
    laptop: 2
    phablet: 1
    tablet: 2
  styles: |
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
  ---
    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      border-left: 4px solid #00C9B7;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin-bottom: 20px;
      }
      ul {
        color: #6B7280;
        padding-left: 20px;
        margin: 0;
      }
      li {
        margin-bottom: 8px;
      }
    ---
    #title
    🚀 Quick Start Guide

    #description
    Get started with the API in 5 minutes

    1. Create an application in the Portal
    2. Register your app with the API
    3. Copy your API key
    4. Make your first API call
    5. Handle the response
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      border-left: 4px solid #003F6C;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin-bottom: 20px;
      }
      ul {
        color: #6B7280;
        padding-left: 20px;
        margin: 0;
      }
      li {
        margin-bottom: 8px;
      }
    ---
    #title
    🔐 Authentication Guide

    #description
    Learn how to authenticate API requests

    - API Key authentication
    - Security best practices
    - Key rotation strategies
    - Error handling
    - Testing authentication
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      border-left: 4px solid #F59E0B;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin-bottom: 20px;
      }
      ul {
        color: #6B7280;
        padding-left: 20px;
        margin: 0;
      }
      li {
        margin-bottom: 8px;
      }
    ---
    #title
    💡 Best Practices

    #description
    Tips for production-ready integrations

    - Rate limiting strategies
    - Error handling patterns
    - Caching recommendations
    - Performance optimization
    - Monitoring and logging
    ::

    ::page-hero
    ---
    full-width: true
    title-font-size: "clamp(22px, 4vw, 28px)"
    title-tag: "h3"
    text-align: "left"
    title-line-height: "clamp(30px, 5vw, 36px)"
    title-font-weight: "700"
    description-font-weight: "400"
    description-font-size: "clamp(15px, 3vw, 16px)"
    description-line-height: "clamp(24px, 4vw, 26px)"
    styles: |
      background: #FFFFFF;
      border-radius: 12px;
      padding: 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      transition: all 0.3s ease;
      height: 100%;
      border-left: 4px solid #10B981;
      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      }
      h3 {
        color: #1F2937;
        margin-bottom: 12px;
      }
      p {
        color: #6B7280;
        margin-bottom: 20px;
      }
      ul {
        color: #6B7280;
        padding-left: 20px;
        margin: 0;
      }
      li {
        margin-bottom: 8px;
      }
    ---
    #title
    🔧 Troubleshooting

    #description
    Common issues and solutions

    - Connection errors
    - Authentication failures
    - Rate limit exceeded
    - Invalid requests
    - Support resources
    ::
  ::
::

::page-section
---
full-width: true
styles: |
  background: #FFFFFF;
  padding: clamp(50px, 7vw, 70px) 0;
---
  ::page-hero
  ---
  full-width: true
  title-font-size: "clamp(24px, 4vw, 32px)"
  title-tag: "h2"
  text-align: "left"
  title-line-height: "clamp(32px, 5vw, 40px)"
  title-font-weight: "700"
  description-font-weight: "400"
  description-font-size: "clamp(15px, 3vw, 16px)"
  description-line-height: "clamp(24px, 4vw, 26px)"
  styles: |
    max-width: 900px;
    margin: 0 auto;
    padding: 0 20px;
    h2 {
      color: #1F2937;
      margin-bottom: 20px;
    }
    h3 {
      color: #003F6C;
      margin-top: 32px;
      margin-bottom: 16px;
      font-size: 20px;
    }
    p {
      color: #6B7280;
      margin-bottom: 16px;
    }
    pre {
      background: #1F2937;
      color: #F9FAFB;
      padding: 24px;
      border-radius: 8px;
      overflow-x: auto;
      margin: 24px 0;
      font-family: 'Monaco', 'Menlo', monospace;
      font-size: 14px;
      line-height: 1.6;
    }
  ---
  #title
  Code Examples

  #description

  ### JavaScript Example

  ```javascript
  const API_KEY = 'your_api_key_here';
  const API_URL = 'https://api.example.com';

  async function getUsers() {
    try {
      const response = await fetch(`${API_URL}/api/v1/users`, {
        headers: {
          'apikey': API_KEY,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log('Users:', data);
      return data;
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  }

  getUsers();
  ```

  ### Python Example

  ```python
  import requests

  API_KEY = 'your_api_key_here'
  API_URL = 'https://api.example.com'

  def get_users():
      headers = {
          'apikey': API_KEY,
          'Content-Type': 'application/json'
      }

      try:
          response = requests.get(f'{API_URL}/api/v1/users', headers=headers)
          response.raise_for_status()
          data = response.json()
          print('Users:', data)
          return data
      except requests.exceptions.RequestException as error:
          print(f'Error fetching users: {error}')

  get_users()
  ```

  ### cURL Example

  ```bash
  curl -X GET "https://api.example.com/api/v1/users" \
    -H "apikey: your_api_key_here" \
    -H "Content-Type: application/json"
  ```
  ::
::
GUIDESEOF

GUIDES_CONTENT=$(cat /tmp/portal-guides.md)

# Check if guides page exists and delete it
EXISTING_GUIDES=$(curl -s "${API_ENDPOINT}/portals/${PORTAL_ID}/pages" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  | jq -r '.data[] | select(.slug=="/guides") | .id')

if [ -n "$EXISTING_GUIDES" ] && [ "$EXISTING_GUIDES" != "null" ]; then
  curl -s -X DELETE "${API_ENDPOINT}/portals/${PORTAL_ID}/pages/${EXISTING_GUIDES}" \
    -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" > /dev/null
fi

# Create guides page
GUIDES_RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/portals/${PORTAL_ID}/pages" \
  -H "Authorization: Bearer ${DECK_KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "/guides",
    "title": "Developer Guides",
    "description": "Step-by-step guides to help you integrate and use our APIs effectively",
    "visibility": "public",
    "content": '"$(echo "$GUIDES_CONTENT" | jq -Rs .)"',
    "status": "published"
  }')

GUIDES_ID=$(echo "$GUIDES_RESPONSE" | jq -r '.id // empty')
if [ -n "$GUIDES_ID" ]; then
  echo -e "${GREEN}✅ Guides page created (ID: ${GUIDES_ID})${NC}"
else
  echo -e "${YELLOW}⚠️  Could not create guides page${NC}"
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
if [ -n "$PAGE_ID" ]; then
  echo "  • Homepage ID: ${PAGE_ID}"
fi
if [ -n "$DOCS_ID" ]; then
  echo "  • Documentation Page ID: ${DOCS_ID}"
fi
if [ -n "$GUIDES_ID" ]; then
  echo "  • Guides Page ID: ${GUIDES_ID}"
fi
if [ -n "$AUTH_STRATEGY_ID" ]; then
  echo "  • Auth Strategy ID: ${AUTH_STRATEGY_ID}"
fi
echo "  • Status: Published"
echo ""
echo -e "${YELLOW}🌐 Next Steps:${NC}"
echo "  1. Visit your Dev Portal URL (check Konnect UI for portal URL)"
echo "  2. Sign up as a developer (if not already registered)"
echo "  3. After login, you should see your published APIs"
echo "  4. Click on '${API_NAME}' in the API catalog"
echo "  5. Click 'Create Application' or go to 'My Apps'"
echo "  6. Create a new application (e.g., 'My Test App')"
echo "  7. Register your app with '${API_NAME}'"
echo "  8. Copy the generated API key (starts with 'kpat_')"
echo "  9. Add to .env: echo 'PORTAL_API_KEY=kpat_your_key' >> ../.env"
echo "  10. Run test script: ./19-test-portal-api.sh"
echo ""
echo -e "${YELLOW}📝 Important:${NC}"
echo "  • Portal keys start with 'kpat_' prefix"
echo "  • Consumer keys (demo-api-key-*) won't work with Portal apps"
echo "  • You must use Portal-generated keys for testing"
echo "  • Portal URL format: https://[org-name].portal.konghq.com"
echo ""
echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
echo "  • If portal is empty: Refresh the page after a few seconds"
echo "  • If no 'My Apps': Check that auto_approve_developers is enabled"
echo "  • Portal URL is available in Konnect UI > Dev Portal section"
echo ""

# Save API ID for test script
echo "$API_ID" > /tmp/portal-api-id.txt
echo -e "${GREEN}💾 API ID saved to /tmp/portal-api-id.txt${NC}"
