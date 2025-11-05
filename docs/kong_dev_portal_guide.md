# Kong Dev Portal - Complete Implementation Guide

> **Documentation Version**: 1.0
> **Last Updated**: November 5, 2025
> **Kong Gateway Version**: 3.12
> **Kong Konnect Region**: India (in.api.konghq.com)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Publishing APIs to Dev Portal](#publishing-apis-to-dev-portal)
5. [Authentication Strategies](#authentication-strategies)
6. [Developer Workflow](#developer-workflow)
7. [Testing & Validation](#testing--validation)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)
10. [References](#references)

---

## Overview

### What is Kong Dev Portal?

Kong Dev Portal is a self-service developer portal that allows API consumers to:
- 🔍 **Discover** published APIs and their documentation
- 📝 **Register** applications to access APIs
- 🔑 **Obtain** credentials automatically
- 🧪 **Test** APIs using interactive documentation
- 📊 **Monitor** API usage and metrics

### Key Concepts

| Concept | Description | Managed By |
|---------|-------------|------------|
| **API Product** | Logical grouping of APIs published to Portal | API Publishers |
| **Application** | Developer's app that consumes APIs | API Consumers |
| **Authentication Strategy** | Method used to authenticate API requests | API Publishers |
| **App Credentials** | Portal-generated keys for applications | Kong Konnect |
| **Gateway Service** | Backend service exposed via Kong Gateway | Platform Team |

### Portal vs Gateway Access

```
┌─────────────────────────────────────────────────────────────────┐
│                     Two Ways to Access APIs                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1️⃣  DEV PORTAL (Recommended for External Developers)          │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Developer → Portal → Register App → Get Credentials →    │ │
│  │ → Test API with Portal-generated key                     │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  2️⃣  DIRECT GATEWAY (For Internal/Backend Testing)             │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Developer → Gateway → Use Pre-configured Consumer Key →  │ │
│  │ → Test API directly                                      │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Kong Konnect                                │
│                                                                     │
│  ┌─────────────────┐        ┌──────────────────┐                  │
│  │   API Catalog   │───────▶│   Dev Portal     │                  │
│  │  (API Products) │        │  (Published APIs)│                  │
│  └────────┬────────┘        └─────────┬────────┘                  │
│           │                            │                            │
│           │  Links to                  │  Generates                │
│           │  Gateway Service           │  App Credentials          │
│           ▼                            ▼                            │
│  ┌─────────────────┐        ┌──────────────────┐                  │
│  │ Control Plane   │        │   Applications   │                  │
│  │  (Kong-Demo)    │        │  (Developer Apps)│                  │
│  └────────┬────────┘        └──────────────────┘                  │
└───────────┼──────────────────────────────────────────────────────┘
            │
            │  Syncs Configuration
            ▼
┌──────────────────────────────────────────────────────────────────┐
│                     Kong Gateway (Data Plane)                     │
│                                                                    │
│  ┌──────────────┐    ┌──────────────┐    ┌────────────────┐    │
│  │   Routes     │───▶│   Plugins    │───▶│   Services     │    │
│  │ (/api/demo)  │    │  (key-auth)  │    │ (demo-api-svc) │    │
│  └──────────────┘    └──────────────┘    └────────┬───────┘    │
│                                                     │             │
└─────────────────────────────────────────────────────┼────────────┘
                                                      │
                                                      ▼
                                        ┌──────────────────────┐
                                        │  Kubernetes Service  │
                                        │   (demo-api-svc)     │
                                        └──────────────────────┘
```

### Authentication Flow

```
┌──────────────────────────────────────────────────────────────────┐
│              Portal Authentication Flow (key-auth)                │
└──────────────────────────────────────────────────────────────────┘

1. Developer Registration
   ┌──────────┐
   │Developer │ Signs up for Dev Portal
   └────┬─────┘
        │
        ▼
   ┌─────────────┐
   │ Dev Portal  │ Creates developer account
   └─────────────┘

2. Application Creation
   ┌──────────┐
   │Developer │ Creates application ("My App")
   └────┬─────┘
        │
        ▼
   ┌─────────────┐
   │ Dev Portal  │ Registers new application
   └─────────────┘

3. API Registration
   ┌──────────┐
   │Developer │ Registers app with API product
   └────┬─────┘
        │
        ▼
   ┌─────────────┐        ┌──────────────┐
   │ Dev Portal  │───────▶│   Konnect    │ Generates API key
   └─────────────┘        └──────┬───────┘
                                 │
                                 ▼
                          ┌─────────────┐
                          │ Credentials │ (e.g., kpat_abc123...)
                          └─────────────┘

4. API Request
   ┌──────────┐
   │Developer │ Makes API request with key
   └────┬─────┘
        │
        │  GET /api/demo/api/v1/users
        │  Header: apikey: kpat_abc123...
        ▼
   ┌──────────────┐      ┌────────────┐      ┌─────────────┐
   │ Kong Gateway │─────▶│  key-auth  │─────▶│   Service   │
   │   (Route)    │      │   Plugin   │      │  (Backend)  │
   └──────────────┘      └────────────┘      └─────────────┘
                              │
                              │ Validates key
                              ▼
                         ✅ Authenticated
                         ❌ 401 Unauthorized
```

---

## Prerequisites

### Required Components

- ✅ **Kong Konnect Account** (India region)
  - Personal Access Token (PAT)
  - Control Plane configured (`Kong-Demo`)
  - Dev Portal enabled

- ✅ **Kong Gateway 3.12+** (DB-less mode)
  - Running in Docker or Kubernetes
  - Connected to Konnect Control Plane
  - Proxy accessible on port 8000

- ✅ **Backend API Service**
  - Deployed in Kubernetes
  - Accessible via Kong Gateway Service
  - Health check endpoint available

- ✅ **OpenAPI Specification**
  - Version 3.0.0 or higher
  - Includes security schemes
  - Documents all endpoints

### Required Tools

```bash
# decK CLI (v1.43+)
brew install deck

# jq (JSON processor)
brew install jq

# curl (HTTP client)
brew install curl

# kubectl (Kubernetes CLI)
brew install kubectl
```

### Environment Setup

Create a `.env` file with your configuration:

```bash
# Kong Konnect Configuration
export KONNECT_TOKEN="kpat_YOUR_TOKEN_HERE"
export KONNECT_REGION="in"  # India region
export KONNECT_API="https://in.api.konghq.com"
export CONTROL_PLANE_NAME="Kong-Demo"

# Kong Gateway Configuration
export KONG_PROXY_URL="http://localhost:8000"
export KONG_ADMIN_URL="http://localhost:8001"

# API Service Configuration
export API_NAME="Demo API"
export API_SERVICE_NAME="demo-api-service"
export API_ROUTE_PATH="/api/demo"

# OpenAPI Spec Location
export OPENAPI_SPEC_PATH="./api-examples/nodejs-api/openapi.yaml"
```

---

## Publishing APIs to Dev Portal

### Overview

Publishing an API to Kong Dev Portal involves:
1. **Registering** the API in the catalog
2. **Uploading** the OpenAPI specification
3. **Linking** to a Gateway Service
4. **Publishing** to the Dev Portal
5. **Configuring** authentication strategy

**Important:** Publishing is done via **Konnect UI or API**, not from Dev Portal itself. The Dev Portal is for API **consumers** to discover and use APIs, not for publishers to onboard them.

### Method 1: UI-Based Publishing (Recommended)

#### Step 1: Register API in Catalog

1. Navigate to **Kong Konnect → Catalog → APIs**
2. Click **"New API"** or **"Create API"**
3. Fill in API details:
   ```
   Name: Demo API
   Description: Sample Node.js REST API with user management
   Version: 1.0.0

   Attributes:
   - Environment: development
   - Domains: web, mobile
   - Team: platform-team
   ```
4. Click **"Create"**
5. **Save the API ID** (visible in URL or API details)

#### Step 2: Upload OpenAPI Specification

1. In your API details page, navigate to **"Specifications"** tab
2. Click **"Upload Specification"** or **"Add Specification"**
3. Select upload method:
   - **File Upload**: Choose your `openapi.yaml` file
   - **URL**: Provide URL to hosted spec
   - **Paste**: Copy and paste spec content
4. Click **"Upload"** or **"Save"**
5. Verify the spec is parsed correctly
6. Check that all endpoints are visible

#### Step 3: Link API to Gateway Service

1. Navigate to **"Implementations"** or **"Gateway Services"** tab
2. Click **"Link Gateway Service"** or **"Add Implementation"**
3. Select configuration:
   ```
   Control Plane: Kong-Demo
   Gateway Service: demo-api-service
   ```
4. Click **"Link"** or **"Save"**
5. Verify the connection is established
6. Check that the service is active and healthy

#### Step 4: Publish to Dev Portal

1. Navigate to **"Portals"** or **"Publications"** tab
2. Click **"Publish to Portal"**
3. Select your Dev Portal
4. Configure publication settings:
   ```
   Visibility: Public
   Auto-approve: Yes (for testing)
   Status: Published
   ```
5. Click **"Publish"**
6. Verify API appears in Dev Portal

#### Step 5: Configure Authentication Strategy

1. While publishing or after publication, set authentication:
   ```
   Authentication Strategy: key-auth
   ```
2. This will:
   - Require developers to register applications
   - Generate API keys automatically
   - Enforce authentication on all API requests

**Result:** Your API is now live in the Dev Portal! 🎉

---

### Method 2: API-Based Publishing (Automation)

For CI/CD pipelines and automation, use the Konnect API.

#### Complete Automation Script

```bash
#!/bin/bash
set -e

# Load environment variables
source .env

# API endpoint
API_ENDPOINT="${KONNECT_API}/v3"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Publishing ${API_NAME} to Kong Dev Portal"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Register API in Catalog
echo ""
echo "📝 Step 1: Registering API in catalog..."
RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/apis" \
  -H "Authorization: Bearer ${KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'"${API_NAME}"'",
    "description": "Sample Node.js REST API with user management",
    "version": "1.0.0",
    "attributes": {
      "env": ["development"],
      "domains": ["web", "mobile"]
    }
  }')

# Extract API ID
API_ID=$(echo "$RESPONSE" | jq -r '.id')
if [ "$API_ID" = "null" ] || [ -z "$API_ID" ]; then
  echo "❌ Failed to create API"
  echo "$RESPONSE" | jq '.'
  exit 1
fi
echo "✅ API registered with ID: ${API_ID}"

# Step 2: Upload OpenAPI Specification
echo ""
echo "📤 Step 2: Uploading OpenAPI specification..."
SPEC_CONTENT=$(cat "${OPENAPI_SPEC_PATH}" | jq -Rs .)
RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/apis/${API_ID}/specifications" \
  -H "Authorization: Bearer ${KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "openapi-spec",
    "content": '"${SPEC_CONTENT}"'
  }')

SPEC_ID=$(echo "$RESPONSE" | jq -r '.id')
if [ "$SPEC_ID" = "null" ] || [ -z "$SPEC_ID" ]; then
  echo "❌ Failed to upload specification"
  echo "$RESPONSE" | jq '.'
  exit 1
fi
echo "✅ Specification uploaded with ID: ${SPEC_ID}"

# Step 3: Get Control Plane ID and Service ID
echo ""
echo "🔍 Step 3: Finding Gateway Service..."

# Get Control Plane ID
CONTROL_PLANE_ID=$(deck gateway dump \
  --konnect-token="${KONNECT_TOKEN}" \
  --konnect-control-plane-name="${CONTROL_PLANE_NAME}" \
  --format json 2>&1 | jq -r '.info.control_plane_id // empty')

if [ -z "$CONTROL_PLANE_ID" ]; then
  echo "❌ Failed to get Control Plane ID"
  exit 1
fi
echo "✅ Control Plane ID: ${CONTROL_PLANE_ID}"

# Get Service ID
SERVICE_ID=$(deck gateway dump \
  --konnect-token="${KONNECT_TOKEN}" \
  --konnect-control-plane-name="${CONTROL_PLANE_NAME}" \
  --format json 2>&1 | jq -r '.services[] | select(.name=="'"${API_SERVICE_NAME}"'") | .id')

if [ -z "$SERVICE_ID" ]; then
  echo "❌ Failed to find service: ${API_SERVICE_NAME}"
  exit 1
fi
echo "✅ Service ID: ${SERVICE_ID}"

# Step 4: Link API to Gateway Service
echo ""
echo "🔗 Step 4: Linking API to Gateway Service..."
RESPONSE=$(curl -s -X POST "${API_ENDPOINT}/apis/${API_ID}/implementations" \
  -H "Authorization: Bearer ${KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "service": {
      "control_plane_id": "'"${CONTROL_PLANE_ID}"'",
      "id": "'"${SERVICE_ID}"'"
    }
  }')

IMPL_ID=$(echo "$RESPONSE" | jq -r '.id')
if [ "$IMPL_ID" = "null" ] || [ -z "$IMPL_ID" ]; then
  echo "❌ Failed to link to Gateway Service"
  echo "$RESPONSE" | jq '.'
  exit 1
fi
echo "✅ API linked to Gateway Service"

# Step 5: Get Portal ID
echo ""
echo "🌐 Step 5: Finding Dev Portal..."
PORTAL_ID=$(curl -s "${API_ENDPOINT}/portals" \
  -H "Authorization: Bearer ${KONNECT_TOKEN}" \
  | jq -r '.data[0].id')

if [ "$PORTAL_ID" = "null" ] || [ -z "$PORTAL_ID" ]; then
  echo "❌ No Dev Portal found"
  exit 1
fi
echo "✅ Portal ID: ${PORTAL_ID}"

# Step 6: Publish API to Dev Portal
echo ""
echo "🚀 Step 6: Publishing to Dev Portal..."
RESPONSE=$(curl -s -X PUT "${API_ENDPOINT}/apis/${API_ID}/publications/${PORTAL_ID}" \
  -H "Authorization: Bearer ${KONNECT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "visibility": "public"
  }')

echo "✅ API published to Dev Portal"

# Step 7 (Optional): Apply Authentication Strategy
echo ""
echo "🔐 Step 7: Applying authentication strategy..."
AUTH_STRATEGY_ID=$(curl -s "${API_ENDPOINT}/portal-auth-strategies" \
  -H "Authorization: Bearer ${KONNECT_TOKEN}" \
  | jq -r '.data[] | select(.name=="key-auth") | .id')

if [ -n "$AUTH_STRATEGY_ID" ] && [ "$AUTH_STRATEGY_ID" != "null" ]; then
  RESPONSE=$(curl -s -X PATCH "${API_ENDPOINT}/apis/${API_ID}/publications/${PORTAL_ID}" \
    -H "Authorization: Bearer ${KONNECT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
      "auth_strategy_ids": ["'"${AUTH_STRATEGY_ID}"'"]
    }')
  echo "✅ Authentication strategy applied (key-auth)"
else
  echo "⚠️  No key-auth strategy found, skipping..."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ API Publishing Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "  • API ID: ${API_ID}"
echo "  • Specification ID: ${SPEC_ID}"
echo "  • Portal ID: ${PORTAL_ID}"
echo "  • Status: Published"
echo ""
echo "🌐 Next Steps:"
echo "  1. Visit Dev Portal to verify publication"
echo "  2. Sign up as a developer"
echo "  3. Create an application"
echo "  4. Register app with '${API_NAME}'"
echo "  5. Test API with Portal-generated key"
echo ""
```

#### Save and Run

```bash
# Save the script
cat > publish-to-portal.sh << 'EOF'
# ... (paste the script above)
EOF

# Make it executable
chmod +x publish-to-portal.sh

# Run it
./publish-to-portal.sh
```

---

## Authentication Strategies

### Supported Strategies

Kong Dev Portal supports multiple authentication strategies:

| Strategy | Description | Use Case | Setup Complexity |
|----------|-------------|----------|------------------|
| **None** | No authentication required | Public APIs | ⭐️ Simple |
| **key-auth** | API key in header | Most common | ⭐️⭐️ Moderate |
| **OAuth 2.0** | OAuth2 authorization flow | Enterprise APIs | ⭐️⭐️⭐️ Complex |
| **OpenID Connect** | OIDC authentication | SSO integration | ⭐️⭐️⭐️⭐️ Advanced |
| **DCR** | Dynamic Client Registration | OAuth2 + auto-registration | ⭐️⭐️⭐️⭐️ Advanced |

### Key-Auth Configuration (Recommended)

#### Why key-auth?

- ✅ Simple to implement
- ✅ Easy for developers to use
- ✅ Works with OpenAPI spec
- ✅ Portal handles key generation
- ✅ No external dependencies

#### OpenAPI Specification

```yaml
openapi: 3.0.3
info:
  title: Demo API
  version: 1.0.0

# Define security schemes
components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: apikey           # Must match Kong Gateway config
      description: |
        API key for authentication. Obtain from Dev Portal:
        1. Sign up for Dev Portal
        2. Create an application
        3. Register application with this API
        4. Copy the generated API key

# Apply to all endpoints
security:
  - ApiKeyAuth: []

paths:
  /api/v1/users:
    get:
      summary: List all users
      security:
        - ApiKeyAuth: []   # Require API key
      responses:
        '200':
          description: Successful response
        '401':
          description: Unauthorized - missing or invalid API key
```

#### Kong Gateway Configuration

```yaml
_format_version: "3.0"

services:
  - name: demo-api-service
    url: http://demo-api-service.default.svc.cluster.local:3000
    routes:
      - name: demo-api-route
        paths:
          - /api/demo
        strip_path: true

        # Add key-auth plugin
        plugins:
          - name: key-auth
            config:
              key_names:
                - apikey        # Must match OpenAPI spec
              key_in_header: true
              key_in_query: false
              key_in_body: false
              hide_credentials: true
```

#### Portal Authentication Strategy

When publishing to Dev Portal:

```yaml
Authentication Strategy: key-auth
Auto-approve: Yes (for testing)
Credential Display: Show after registration
```

### Authentication Flow Comparison

#### Dev Portal Authentication (Portal App Keys)

```
Developer → Portal → Create App → Register with API
    ↓
Portal generates unique key (e.g., kpat_abc123xyz...)
    ↓
Developer uses key in requests
    ↓
Kong validates via key-auth plugin
    ↓
Request succeeds ✅
```

#### Direct Gateway Authentication (Consumer Keys)

```
Platform Team → Configure Consumer → Create API Key
    ↓
Pre-configured key (e.g., demo-api-key-12345)
    ↓
Backend/Internal services use key
    ↓
Kong validates via key-auth plugin
    ↓
Request succeeds ✅
```

### Key Differences

| Aspect | Portal App Keys | Consumer Keys |
|--------|----------------|---------------|
| **Generated By** | Dev Portal (automatic) | Manual configuration |
| **Prefix** | `kpat_*` | Custom |
| **Use Case** | External developers | Internal/backend |
| **Management** | Self-service via Portal | Admin-managed |
| **Visibility** | Visible in "My Apps" | Configured in Gateway |
| **Revocation** | Developer or Admin | Admin only |

**Critical:** You **cannot** use consumer keys (like `demo-api-key-12345`) when testing from Dev Portal. You **must** use Portal-generated app keys.

---

## Developer Workflow

### Complete Developer Journey

```
┌──────────────────────────────────────────────────────────────────┐
│                     Developer Onboarding                          │
└──────────────────────────────────────────────────────────────────┘

Step 1: Discovery
┌──────────┐
│Developer │ Browses Dev Portal
└────┬─────┘
     │ Finds "Demo API"
     │ Reads documentation
     │ Reviews endpoints
     ▼
┌─────────────┐
│   Portal    │ Shows API details
└─────────────┘

Step 2: Registration
┌──────────┐
│Developer │ Signs up for Portal access
└────┬─────┘
     │ Email: developer@example.com
     │ Password: ********
     ▼
┌─────────────┐
│   Portal    │ Creates developer account
└─────────────┘

Step 3: Application Creation
┌──────────┐
│Developer │ Creates application
└────┬─────┘
     │ Name: "My Mobile App"
     │ Description: "iOS app for user management"
     ▼
┌─────────────┐
│   Portal    │ Registers application
└─────────────┘

Step 4: API Registration
┌──────────┐
│Developer │ Registers app with "Demo API"
└────┬─────┘
     │
     ▼
┌─────────────┐        ┌──────────────┐
│   Portal    │───────▶│  Konnect     │ Generates API key
└─────────────┘        └──────┬───────┘
                              │
                              ▼
                       ┌──────────────┐
                       │  Credentials │
                       │ kpat_abc123  │
                       └──────────────┘

Step 5: Testing
┌──────────┐
│Developer │ Tests API in Portal
└────┬─────┘
     │ Uses "Try it" feature
     │ Key auto-included
     ▼
┌─────────────┐
│   Portal    │ Makes request to Gateway
└──────┬──────┘
       │
       ▼
┌──────────────┐      ┌────────────┐      ┌─────────────┐
│    Gateway   │─────▶│  key-auth  │─────▶│   Backend   │
└──────────────┘      └────────────┘      └─────────────┘
       │                     │                     │
       │                     │                     │
       ▼                     ▼                     ▼
  ✅ 200 OK          ✅ Valid Key         ✅ Response

Step 6: Integration
┌──────────┐
│Developer │ Integrates into app
└────┬─────┘
     │
     │ // Mobile app code
     │ const API_KEY = 'kpat_abc123';
     │ const API_URL = 'https://api.example.com';
     │
     │ fetch(`${API_URL}/api/demo/api/v1/users`, {
     │   headers: {
     │     'apikey': API_KEY
     │   }
     │ });
     ▼
   Production! 🚀
```

### Step-by-Step Instructions

#### 1. Sign Up for Dev Portal

```
1. Navigate to your Dev Portal URL
   Example: https://kong-demo.portal.konghq.com

2. Click "Sign Up" or "Register"

3. Fill in registration form:
   - Email: your-email@example.com
   - Password: (strong password)
   - Name: Your Name
   - Organization: Your Company

4. Verify email (if required)

5. Log in to Portal
```

#### 2. Create Application

```
1. Navigate to "My Apps" or "Applications"

2. Click "Create Application" or "New App"

3. Fill in application details:
   - Name: My Mobile App
   - Description: iOS app for user management
   - Type: Mobile App
   - Callback URL: (if using OAuth2)

4. Click "Create"

5. Note the Application ID
```

#### 3. Register with API Product

```
1. Browse to "APIs" or "Catalog"

2. Find "Demo API"

3. Click "Register" or "Subscribe"

4. Select your application: "My Mobile App"

5. Review permissions and terms

6. Click "Register" or "Subscribe"

7. Wait for approval (or auto-approved if configured)
```

#### 4. Obtain Credentials

```
1. Go to "My Apps" → "My Mobile App"

2. Navigate to "Credentials" or "Keys" tab

3. Locate API key for "Demo API":
   Key: kpat_abc123xyz789...
   Status: Active
   Created: 2025-11-05

4. Copy the API key

5. Store securely (never commit to git!)
```

#### 5. Test API

##### Option A: Test in Portal

```
1. Navigate to "Demo API" in Portal

2. Browse to endpoint: GET /api/v1/users

3. Click "Try it" or "Test"

4. Portal auto-includes your API key

5. Click "Execute"

6. Verify response:
   Status: 200 OK
   Body: [
     { "id": 1, "name": "John Doe", ... },
     { "id": 2, "name": "Jane Smith", ... }
   ]
```

##### Option B: Test with curl

```bash
# Set API key
export API_KEY="kpat_abc123xyz789..."

# Test endpoint
curl -X GET "http://localhost:8000/api/demo/api/v1/users" \
  -H "apikey: ${API_KEY}" \
  -H "Content-Type: application/json"

# Expected response:
# Status: 200 OK
# Body: [{"id":1,"name":"John Doe",...}]
```

##### Option C: Test with Postman

```
1. Create new request
2. Method: GET
3. URL: http://localhost:8000/api/demo/api/v1/users
4. Headers:
   - Key: apikey
   - Value: kpat_abc123xyz789...
5. Send request
6. Verify 200 OK response
```

#### 6. Monitor Usage

```
1. Go to "My Apps" → "My Mobile App"

2. Navigate to "Analytics" or "Usage" tab

3. View metrics:
   - Total requests
   - Success rate
   - Error rate
   - Latency percentiles

4. Review rate limits:
   - Limit: 1000 requests/minute
   - Current: 45 requests/minute
   - Status: Within limits ✅
```

---

## Testing & Validation

### Test Scenarios

#### Scenario 1: Successful Authentication

```bash
# Test with valid Portal-generated key
curl -X GET "http://localhost:8000/api/demo/api/v1/users" \
  -H "apikey: kpat_abc123xyz789..." \
  -H "Content-Type: application/json"

# Expected:
# HTTP/1.1 200 OK
# Content-Type: application/json
#
# [
#   {"id": 1, "name": "John Doe", "email": "john@example.com"},
#   {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
# ]
```

#### Scenario 2: Missing API Key

```bash
# Test without API key
curl -X GET "http://localhost:8000/api/demo/api/v1/users" \
  -H "Content-Type: application/json"

# Expected:
# HTTP/1.1 401 Unauthorized
# Content-Type: application/json
#
# {
#   "message": "No API key found in request"
# }
```

#### Scenario 3: Invalid API Key

```bash
# Test with invalid key
curl -X GET "http://localhost:8000/api/demo/api/v1/users" \
  -H "apikey: invalid-key-12345" \
  -H "Content-Type: application/json"

# Expected:
# HTTP/1.1 401 Unauthorized
# Content-Type: application/json
#
# {
#   "message": "Invalid authentication credentials"
# }
```

#### Scenario 4: Expired/Revoked Key

```bash
# Test with revoked key
curl -X GET "http://localhost:8000/api/demo/api/v1/users" \
  -H "apikey: kpat_revoked_key..." \
  -H "Content-Type: application/json"

# Expected:
# HTTP/1.1 401 Unauthorized
# Content-Type: application/json
#
# {
#   "message": "API key has been revoked"
# }
```

#### Scenario 5: Wrong Header Name

```bash
# Test with wrong header name
curl -X GET "http://localhost:8000/api/demo/api/v1/users" \
  -H "Authorization: Bearer kpat_abc123..." \
  -H "Content-Type: application/json"

# Expected:
# HTTP/1.1 401 Unauthorized
#
# {
#   "message": "No API key found in request"
# }
```

### Validation Checklist

Before going to production, validate:

#### API Publication
- [ ] API registered in Konnect catalog
- [ ] OpenAPI spec uploaded successfully
- [ ] API linked to correct Gateway Service
- [ ] API published to Dev Portal
- [ ] API visible in Portal (check as logged-out user)
- [ ] Documentation renders correctly
- [ ] All endpoints documented

#### Authentication Configuration
- [ ] Authentication strategy selected (key-auth)
- [ ] Strategy applied to publication
- [ ] Portal application auth configured
- [ ] Key header name matches (`apikey`)
- [ ] OpenAPI spec includes security scheme
- [ ] Gateway service has key-auth plugin

#### Developer Experience
- [ ] Registration workflow works
- [ ] Application creation works
- [ ] API registration/subscription works
- [ ] Credentials generated automatically
- [ ] Credentials visible in Portal
- [ ] "Try it" feature works
- [ ] API requests succeed with Portal key

#### Gateway Configuration
- [ ] Service configured correctly
- [ ] Route configured correctly
- [ ] key-auth plugin enabled
- [ ] Plugin configuration matches OpenAPI spec
- [ ] Backend service reachable
- [ ] Health check passing

#### Error Handling
- [ ] 401 for missing API key
- [ ] 401 for invalid API key
- [ ] 401 for revoked API key
- [ ] 429 for rate limit exceeded
- [ ] 500 errors handled gracefully
- [ ] Error messages are clear

---

## Troubleshooting

### Common Issues

#### Issue 1: 401 Unauthorized in Dev Portal

**Symptoms:**
- Testing from Portal returns 401
- Error: "No API key found in request"
- Error: "Invalid authentication credentials"

**Possible Causes:**
- ❌ Application not registered with API
- ❌ Using wrong type of key (consumer key instead of app key)
- ❌ API key revoked or expired
- ❌ Wrong header name in requests
- ❌ Authentication strategy not configured

**Diagnosis:**
```bash
# Step 1: Verify API is published with auth strategy
deck gateway dump \
  --konnect-token="$KONNECT_TOKEN" \
  --konnect-control-plane-name="Kong-Demo" \
  --format yaml | grep -A 10 "demo-api"

# Step 2: Check application registration
# → Log in to Portal
# → Go to "My Apps"
# → Verify app is registered with "Demo API"
# → Check credential status (should be "Active")

# Step 3: Test with Portal-generated key
export PORTAL_KEY="kpat_your_portal_key_here"
curl -v -H "apikey: $PORTAL_KEY" \
  http://localhost:8000/api/demo/api/v1/users

# Step 4: Check Gateway logs
kubectl logs -l app=kong-gateway --tail=50

# Look for:
# - "No API key found in request"
# - "Invalid authentication credentials"
# - Plugin errors
```

**Solutions:**

1. **Register Application with API:**
   ```
   Portal → My Apps → [Your App] → Register with API → Select "Demo API"
   ```

2. **Use Portal-Generated Key:**
   ```bash
   # ❌ Wrong: Using pre-configured consumer key
   apikey: demo-api-key-12345

   # ✅ Correct: Using Portal-generated app key
   apikey: kpat_abc123xyz789...
   ```

3. **Verify Credential Status:**
   ```
   Portal → My Apps → [Your App] → Credentials → Check "Active" status
   ```

4. **Check Header Name:**
   ```bash
   # ❌ Wrong header name
   curl -H "Authorization: Bearer key"

   # ✅ Correct header name
   curl -H "apikey: key"
   ```

---

#### Issue 2: API Not Visible in Dev Portal

**Symptoms:**
- API doesn't appear in Portal catalog
- Developers can't find the API
- Search returns no results

**Diagnosis:**
```bash
# Check publication status via Konnect API
curl -s "https://in.api.konghq.com/v3/apis" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.data[] | select(.name=="Demo API")'

# Check if published to Portal
curl -s "https://in.api.konghq.com/v3/apis/${API_ID}/publications" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.'
```

**Solutions:**

1. **Verify Publication:**
   ```
   Konnect → APIs → Demo API → Portals → Check "Published" status
   ```

2. **Check Visibility:**
   ```
   Publication Settings → Visibility → Should be "Public"
   ```

3. **Re-publish if Needed:**
   ```bash
   curl -X PUT "https://in.api.konghq.com/v3/apis/${API_ID}/publications/${PORTAL_ID}" \
     -H "Authorization: Bearer $KONNECT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"visibility": "public"}'
   ```

---

#### Issue 3: OpenAPI Spec Not Loading

**Symptoms:**
- Portal shows "Specification not found"
- Endpoints not visible in Portal
- "Try it" feature doesn't work

**Diagnosis:**
```bash
# Check spec upload status
curl -s "https://in.api.konghq.com/v3/apis/${API_ID}/specifications" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.'

# Validate OpenAPI spec locally
npx @stoplight/spectral-cli lint openapi.yaml
```

**Solutions:**

1. **Validate Spec:**
   ```bash
   # Use Spectral or OpenAPI validator
   npx @stoplight/spectral-cli lint openapi.yaml

   # Fix any errors before uploading
   ```

2. **Re-upload Spec:**
   ```bash
   SPEC_CONTENT=$(cat openapi.yaml | jq -Rs .)
   curl -X POST "https://in.api.konghq.com/v3/apis/${API_ID}/specifications" \
     -H "Authorization: Bearer $KONNECT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "openapi-spec",
       "content": '"${SPEC_CONTENT}"'
     }'
   ```

3. **Check Spec Format:**
   ```yaml
   # Ensure proper OpenAPI 3.x format
   openapi: 3.0.3  # Must be 3.0.x or 3.1.x
   info:
     title: Demo API
     version: 1.0.0
   ```

---

#### Issue 4: Gateway Service Not Linked

**Symptoms:**
- API published but requests fail
- 404 Not Found errors
- Service unreachable

**Diagnosis:**
```bash
# Check API implementations
curl -s "https://in.api.konghq.com/v3/apis/${API_ID}/implementations" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.'

# Check Gateway service exists
deck gateway dump \
  --konnect-token="$KONNECT_TOKEN" \
  --konnect-control-plane-name="Kong-Demo" \
  --format json | jq '.services[] | select(.name=="demo-api-service")'
```

**Solutions:**

1. **Link to Gateway Service:**
   ```bash
   # Get Control Plane ID and Service ID
   CONTROL_PLANE_ID="..."
   SERVICE_ID="..."

   # Link API to service
   curl -X POST "https://in.api.konghq.com/v3/apis/${API_ID}/implementations" \
     -H "Authorization: Bearer $KONNECT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "service": {
         "control_plane_id": "'"${CONTROL_PLANE_ID}"'",
         "id": "'"${SERVICE_ID}"'"
       }
     }'
   ```

2. **Verify Service Health:**
   ```bash
   # Test backend service directly
   kubectl port-forward svc/demo-api-service 3000:3000
   curl http://localhost:3000/health
   ```

3. **Check Route Configuration:**
   ```bash
   # Verify route exists and is correct
   deck gateway dump \
     --konnect-token="$KONNECT_TOKEN" \
     --konnect-control-plane-name="Kong-Demo" \
     --format yaml | grep -A 20 "demo-api-route"
   ```

---

### Debug Commands

#### Check Konnect Configuration

```bash
# List all APIs in catalog
curl -s "https://in.api.konghq.com/v3/apis" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.data[] | {name, id, version}'

# Get specific API details
curl -s "https://in.api.konghq.com/v3/apis/${API_ID}" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.'

# List Dev Portals
curl -s "https://in.api.konghq.com/v3/portals" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.data[] | {name, id}'

# Check publications
curl -s "https://in.api.konghq.com/v3/apis/${API_ID}/publications" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.'

# List authentication strategies
curl -s "https://in.api.konghq.com/v3/portal-auth-strategies" \
  -H "Authorization: Bearer $KONNECT_TOKEN" \
  | jq '.data[] | {name, id}'
```

#### Check Gateway Configuration

```bash
# Dump entire Gateway config
deck gateway dump \
  --konnect-token="$KONNECT_TOKEN" \
  --konnect-control-plane-name="Kong-Demo" \
  --output-file gateway-config.yaml

# Check specific service
deck gateway dump \
  --konnect-token="$KONNECT_TOKEN" \
  --konnect-control-plane-name="Kong-Demo" \
  --format json | jq '.services[] | select(.name=="demo-api-service")'

# Check plugins on route
deck gateway dump \
  --konnect-token="$KONNECT_TOKEN" \
  --konnect-control-plane-name="Kong-Demo" \
  --format json | jq '.plugins[] | select(.route=="demo-api-route")'

# Verify key-auth plugin config
deck gateway dump \
  --konnect-token="$KONNECT_TOKEN" \
  --konnect-control-plane-name="Kong-Demo" \
  --format json | jq '.plugins[] | select(.name=="key-auth")'
```

#### Test API Endpoints

```bash
# Test without authentication (should fail)
curl -v http://localhost:8000/api/demo/api/v1/users

# Test with consumer key (direct Gateway access)
curl -v -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users

# Test with Portal app key (Portal access)
curl -v -H "apikey: kpat_abc123..." \
  http://localhost:8000/api/demo/api/v1/users

# Test health endpoint (public, no auth)
curl -v http://localhost:8000/ai/health
```

#### Check Kubernetes Resources

```bash
# Check service status
kubectl get svc demo-api-service -n default

# Check pod status
kubectl get pods -l app=demo-api -n default

# Check pod logs
kubectl logs -l app=demo-api -n default --tail=50

# Test service internally
kubectl run curl-test --image=curlimages/curl -it --rm -- \
  curl http://demo-api-service.default.svc.cluster.local:3000/health
```

#### Monitor Gateway Logs

```bash
# Kong Gateway logs
kubectl logs -l app=kong-gateway --tail=100 -f

# Filter for authentication errors
kubectl logs -l app=kong-gateway --tail=500 | grep -i "authentication"

# Filter for specific API
kubectl logs -l app=kong-gateway --tail=500 | grep "demo-api"

# Check plugin execution
kubectl logs -l app=kong-gateway --tail=500 | grep "key-auth"
```

---

## Best Practices

### API Design

#### 1. Use Semantic Versioning

```yaml
openapi: 3.0.3
info:
  title: Demo API
  version: 1.0.0  # Major.Minor.Patch

paths:
  /api/v1/users:  # Version in path
    get:
      summary: List users
```

**Benefits:**
- Clear version communication
- Backward compatibility
- Easier deprecation

#### 2. Document Everything

```yaml
paths:
  /api/v1/users:
    get:
      summary: List all users
      description: |
        Returns a paginated list of all users in the system.
        Requires authentication via API key.

      parameters:
        - name: page
          in: query
          description: Page number for pagination (default: 1)
          schema:
            type: integer
            minimum: 1
            default: 1

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
        '429':
          description: Rate limit exceeded
```

#### 3. Use Standard HTTP Methods

```yaml
paths:
  /api/v1/users:
    get:      # List resources
    post:     # Create resource

  /api/v1/users/{id}:
    get:      # Get resource
    put:      # Update resource (full)
    patch:    # Update resource (partial)
    delete:   # Delete resource
```

#### 4. Implement Proper Error Responses

```yaml
responses:
  '400':
    description: Bad Request
    content:
      application/json:
        schema:
          type: object
          properties:
            error:
              type: string
              example: "Invalid request parameters"
            details:
              type: array
              items:
                type: string

  '401':
    description: Unauthorized
    content:
      application/json:
        schema:
          type: object
          properties:
            message:
              type: string
              example: "No API key found in request"
```

---

### Security

#### 1. Use HTTPS in Production

```yaml
servers:
  - url: https://api.example.com
    description: Production server (HTTPS only)
  - url: http://localhost:8000
    description: Development server
```

#### 2. Implement Rate Limiting

```yaml
# Kong Gateway config
plugins:
  - name: rate-limiting
    route: demo-api-route
    config:
      minute: 1000        # 1000 requests per minute
      hour: 50000         # 50000 requests per hour
      policy: redis       # Use Redis for distributed rate limiting
```

#### 3. Use API Key Rotation

```
Recommended rotation schedule:
- Development: 90 days
- Production: 30-90 days
- After security incident: Immediate
```

#### 4. Monitor and Alert

```bash
# Set up alerts for:
- High rate of 401 errors (potential attack)
- Unusual traffic patterns
- Repeated failed authentication attempts
- API key usage from unexpected IPs
```

#### 5. Restrict Key Permissions

```yaml
# Define fine-grained permissions
applications:
  - name: "Mobile App"
    permissions:
      - read:users
      - write:users

  - name: "Analytics Dashboard"
    permissions:
      - read:users
      - read:analytics
```

---

### Portal Configuration

#### 1. Customize Portal Branding

```
Settings → Appearance:
- Logo: Your company logo
- Color scheme: Match your brand
- Custom domain: portal.yourcompany.com
- Favicon: Your favicon
```

#### 2. Configure Auto-Approval

```yaml
# For internal developers
auto_approve: true
approval_required: false

# For external developers
auto_approve: false
approval_required: true
approval_workflow:
  - review_by: api-team@company.com
  - sla: 24 hours
```

#### 3. Set Up Email Notifications

```yaml
notifications:
  - event: application_created
    recipients: [api-team@company.com]

  - event: api_key_generated
    recipients: [developer]

  - event: rate_limit_exceeded
    recipients: [developer, api-team@company.com]
```

#### 4. Enable Analytics

```
Portal → Analytics:
- Track API usage per developer
- Monitor most popular endpoints
- Identify slow endpoints
- Detect error patterns
```

---

### Developer Experience

#### 1. Provide Code Examples

```yaml
# In OpenAPI spec
paths:
  /api/v1/users:
    get:
      x-codeSamples:
        - lang: cURL
          source: |
            curl -X GET "https://api.example.com/api/v1/users" \
              -H "apikey: YOUR_API_KEY"

        - lang: JavaScript
          source: |
            const response = await fetch('https://api.example.com/api/v1/users', {
              headers: {
                'apikey': 'YOUR_API_KEY'
              }
            });
            const users = await response.json();

        - lang: Python
          source: |
            import requests

            response = requests.get(
                'https://api.example.com/api/v1/users',
                headers={'apikey': 'YOUR_API_KEY'}
            )
            users = response.json()
```

#### 2. Create Getting Started Guide

```markdown
# Getting Started with Demo API

## 1. Sign Up
Visit https://portal.yourcompany.com and create an account.

## 2. Create Application
Go to "My Apps" and create your first application.

## 3. Get API Key
Register your app with "Demo API" to receive an API key.

## 4. Make Your First Request
```bash
curl -H "apikey: YOUR_API_KEY" \
  https://api.yourcompany.com/api/v1/users
```

## 5. Explore Documentation
Browse all available endpoints in the Portal.
```

#### 3. Offer SDKs and Client Libraries

```
Available SDKs:
- JavaScript/TypeScript: npm install @yourcompany/demo-api-sdk
- Python: pip install yourcompany-demo-api
- Java: Add Maven dependency
- Go: go get github.com/yourcompany/demo-api-go
```

#### 4. Provide Sandbox Environment

```yaml
# Separate environments
environments:
  - name: sandbox
    url: https://sandbox.api.yourcompany.com
    description: Test environment with sample data

  - name: production
    url: https://api.yourcompany.com
    description: Production environment
```

---

## References

### Official Documentation

- [Kong Dev Portal Docs](https://docs.konghq.com/konnect/dev-portal/)
- [API Products](https://docs.konghq.com/konnect/api-products/)
- [Application Registration](https://docs.konghq.com/konnect/dev-portal/applications/)
- [Authentication Strategies](https://developer.konghq.com/dev-portal/auth-strategies/)
- [Key Authentication Plugin](https://docs.konghq.com/hub/kong-inc/key-auth/)
- [Konnect API Reference](https://developer.konghq.com/api/)

### Tutorials

- [Publish your API to Dev Portal](https://developer.konghq.com/catalog/apis/#publish-your-api-to-dev-portal)
- [Enable key authentication for Dev Portal apps](https://developer.konghq.com/how-to/enable-key-auth-for-dev-portal/)
- [Automate API catalog with Konnect API](https://developer.konghq.com/how-to/automate-api-catalog/)
- [Developer self-service and app registration](https://developer.konghq.com/dev-portal/self-service/)

### Tools

- [decK CLI](https://docs.konghq.com/deck/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Spectral Linter](https://stoplight.io/open-source/spectral)
- [Postman](https://www.postman.com/)

---

## Appendix

### Quick Reference Commands

```bash
# Publish API to Portal (automated)
./publish-to-portal.sh

# Check Gateway configuration
deck gateway dump \
  --konnect-token="$KONNECT_TOKEN" \
  --konnect-control-plane-name="Kong-Demo"

# Test API with Portal key
curl -H "apikey: $PORTAL_KEY" \
  http://localhost:8000/api/demo/api/v1/users

# View Gateway logs
kubectl logs -l app=kong-gateway --tail=50

# Check service health
kubectl get svc demo-api-service
```

### Environment Variables

```bash
# Required
KONNECT_TOKEN="kpat_..."
KONNECT_REGION="in"
CONTROL_PLANE_NAME="Kong-Demo"

# Optional
API_NAME="Demo API"
API_SERVICE_NAME="demo-api-service"
OPENAPI_SPEC_PATH="./openapi.yaml"
```

### Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| 401 Unauthorized | Missing/invalid API key | Use Portal-generated key |
| 404 Not Found | Wrong path or route | Check route configuration |
| 429 Too Many Requests | Rate limit exceeded | Wait or request limit increase |
| 500 Internal Server Error | Backend service down | Check service health |

---

**Document Version:** 1.0
**Last Updated:** November 5, 2025
**Maintained By:** Platform Team
**Contact:** platform-team@example.com

For questions or issues, please contact the Platform Team or open a ticket in the support portal.
