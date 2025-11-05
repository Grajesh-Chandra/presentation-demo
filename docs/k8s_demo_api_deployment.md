# Deploying Demo API to Kubernetes

**Reference guide for the Demo API service deployment (automated via scripts/01-install-services.sh)**

> **Note:** This is a reference guide. For the recommended automated setup, use `scripts/01-install-services.sh` instead.



## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Part 1: Build Demo API Docker Image](#part-1-build-demo-api-docker-image)
4. [Part 2: Deploy to Kubernetes](#part-2-deploy-to-kubernetes)
5. [Part 3: Test Demo API](#part-3-test-demo-api)
6. [Part 4: Connect to Kong Konnect](#part-4-connect-to-kong-konnect)
7. [Part 5: Configure Kong Routes](#part-5-configure-kong-routes)
8. [Part 6: Add Authentication](#part-6-add-authentication)
9. [Part 7: Enable Rate Limiting](#part-7-enable-rate-limiting)
10. [Part 8: Verify Complete Setup](#part-8-verify-complete-setup)
11. [Troubleshooting](#troubleshooting)
12. [Clean Up](#clean-up)



## Overview

This is a **reference guide** for understanding the Demo API deployment.

**Recommended Approach:** Use the automated scripts:
```bash
cd scripts
./01-install-services.sh  # Deploys Demo API + AI Router
./02-test-without-kong.sh # Tests services directly
./03-configure-kong-basic.sh # Generates Kong config
# ... continue with numbered scripts
```

**Manual deployment covered in this guide:**
- ✅ Build Node.js Demo API Docker image
- ✅ Deploy to Kubernetes with 2 replicas
- ✅ Create service for cluster communication
- ✅ Configure health checks
- ✅ Connect Kong Konnect data plane (Kong Gateway 3.8)
- ✅ Configure routes through Konnect (India region)
- ✅ Add authentication and rate limiting
- ✅ Test end-to-end

**Architecture:**

```
┌─────────────────────────────────────┐
│  Kong Konnect Control Plane         │
│  (Cloud: *.cp.konghq.com)           │
│  • Configuration Management         │
│  • Analytics Dashboard              │
└────────────┬────────────────────────┘
             │ HTTPS/MTLS
             ▼
┌─────────────────────────────────────┐
│  Kong Data Plane (Docker)           │
│  localhost:8000 (HTTP)              │
└────────────┬────────────────────────┘
             │ via host.docker.internal:3000
             ▼
┌─────────────────────────────────────┐
│  Demo API Service (Kubernetes)      │
│  • 2 replicas for HA                │
│  • Health checks                    │
│  • Port 3000                        │
└─────────────────────────────────────┘
```



## Prerequisites

### Required Software

```bash
# 1. Docker Desktop with Kubernetes enabled
docker --version
# Docker version 20.10.x or higher

kubectl version --client
# kubectl version v1.24.x or higher

# 2. Verify Kubernetes is running
kubectl cluster-info
# Should show: "Kubernetes control plane is running at..."

# 3. Node.js (for local development/testing)
node --version
# Node.js v16.x or higher

# 4. jq (for JSON parsing - optional but helpful)
brew install jq
```

### Kong Konnect Account

1. Sign up at https://cloud.konghq.com (free tier available)
2. Create a Runtime Group (e.g., "Kong-demo")
3. Get your connection details ready (we'll use them in Part 4)



## Part 1: Build Demo API Docker Image

### Step 1.1: Review Demo API Structure

```bash
cd presentation-demo/api-examples/nodejs-api

# Note: Replace 'presentation-demo' with your actual cloned directory name

# Check files
ls -la
# Expected:
# - server.js (Express.js application)
# - package.json (dependencies)
# - Dockerfile (build instructions)
# - deployment.yaml (Kubernetes config)
# - healthcheck.js (health endpoint)
```

**Demo API Endpoints:**
- `GET /health` - Health check
- `GET /api/v1/users` - List users
- `GET /api/v1/users/:id` - Get user by ID
- `GET /api/v1/products` - List products
- `GET /api/v1/products/:id` - Get product by ID
- `GET /api/v1/stats` - API statistics

### Step 1.2: Build Docker Image

```bash
# Build the image
docker build -t demo-api:latest .

# This will:
# 1. Use Node.js 16 Alpine base image
# 2. Copy package files and install dependencies
# 3. Copy application code
# 4. Expose port 3000
# 5. Set startup command

# Verify image was created
docker images | grep demo-api

# Expected output:
# demo-api    latest    abc123def456    2 minutes ago    152MB
```

### Step 1.3: Test Image Locally (Optional)

```bash
# Run container locally
docker run -d -p 3000:3000 --name demo-api-test demo-api:latest

# Test endpoints
curl http://localhost:3000/health
# Expected: {"status":"healthy","timestamp":"..."}

curl http://localhost:3000/api/v1/users
# Expected: {"success":true,"data":[...],"count":3}

# Stop and remove test container
docker stop demo-api-test
docker rm demo-api-test
```



## Part 2: Deploy to Kubernetes

### Step 2.1: Create Namespace

```bash
cd presentation-demo

# Create namespace
kubectl apply -f kubernetes/namespace.yaml

# Verify namespace exists
kubectl get namespace demo-apis
# Expected: NAME         STATUS   AGE
#           demo-apis    Active   5s
```

**Note:** You may see warnings about missing annotations - these are informational and auto-patched.

### Step 2.2: Deploy Demo API

```bash
# Deploy to Kubernetes
kubectl apply -f api-examples/nodejs-api/deployment.yaml

# Wait for deployment to be ready (may take 30-60 seconds)
kubectl wait --for=condition=available deployment/demo-api -n demo-apis --timeout=120s

# Check deployment status
kubectl get deployments -n demo-apis

# Expected output:
# NAME        READY   UP-TO-DATE   AVAILABLE   AGE
# demo-api    2/2     2            2           1m
```

### Step 2.3: Verify Pods are Running

```bash
# Check pods
kubectl get pods -n demo-apis

# Expected output:
# NAME                        READY   STATUS    RESTARTS   AGE
# demo-api-5fb87b6b8f-abc12   1/1     Running   0          1m
# demo-api-5fb87b6b8f-def34   1/1     Running   0          1m

# Check detailed pod information
kubectl describe pods -n demo-apis -l app=demo-api
```

### Step 2.4: Check Service

```bash
# View service
kubectl get svc -n demo-apis

# Expected output:
# NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# demo-api   ClusterIP   10.96.100.50    <none>        3000/TCP   1m

# Check service endpoints
kubectl get endpoints demo-api -n demo-apis

# Expected:
# NAME       ENDPOINTS                         AGE
# demo-api   10.1.0.5:3000,10.1.0.6:3000      1m
```



## Part 3: Test Demo API

### Step 3.1: Port Forward to Service

```bash
# Port forward to demo-api service
kubectl port-forward -n demo-apis svc/demo-api 3000:3000 &

# This runs in background and maps:
# localhost:3000 → demo-api service:3000 → demo-api pods:3000
```

### Step 3.2: Test All Endpoints

```bash
# Test health endpoint
curl http://localhost:3000/health
# Expected: {"status":"healthy","timestamp":"2025-11-02T..."}

# Test users endpoint
curl http://localhost:3000/api/v1/users
# Expected: {
#   "success": true,
#   "data": [
#     {"id": 1, "name": "Alice", "email": "alice@example.com"},
#     {"id": 2, "name": "Bob", "email": "bob@example.com"},
#     {"id": 3, "name": "Charlie", "email": "charlie@example.com"}
#   ],
#   "count": 3,
#   "consumer": "anonymous"
# }

# Test single user
curl http://localhost:3000/api/v1/users/1
# Expected: {
#   "success": true,
#   "data": {"id": 1, "name": "Alice", "email": "alice@example.com"}
# }

# Test products endpoint
curl http://localhost:3000/api/v1/products
# Expected: {
#   "success": true,
#   "data": [
#     {"id": 1, "name": "Product A", "price": 29.99},
#     {"id": 2, "name": "Product B", "price": 49.99}
#   ],
#   "count": 2
# }

# Test stats endpoint
curl http://localhost:3000/api/v1/stats
# Expected: {
#   "success": true,
#   "data": {
#     "totalRequests": 5,
#     "uptime": "120 seconds",
#     "version": "1.0.0"
#   }
# }
```

✅ **All endpoints working!** Your Demo API is successfully deployed to Kubernetes.



## Part 4: Connect to Kong Konnect

### Step 4.1: Get Konnect Control Plane Details

1. **Log in to Kong Konnect**: https://cloud.konghq.com
2. **Navigate to API Gateway** → Click on create New Gateway (Self-hosted) and name it **Kong-Demo**
3. **Click on "Create"**
4. **Copy the connection details and Paste it your terminal:**


### Step 4.2: Deploy Kong Data Plane

```bash
# Navigate to project root
cd presentation-demo

# Run Kong Data Plane connected to Konnect
docker run -d \
  --name kong-demo-dp \
  --network bridge \
  -e "KONG_ROLE=data_plane" \
  -e "KONG_DATABASE=off" \
  -e "KONG_VITALS=off" \
  -e "KONG_CLUSTER_MTLS=pki" \
  -e "KONG_CLUSTER_CONTROL_PLANE=<YOUR_CP_ENDPOINT>:443" \
  -e "KONG_CLUSTER_SERVER_NAME=<YOUR_CP_ENDPOINT>" \
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=<YOUR_TP_ENDPOINT>:443" \
  -e "KONG_CLUSTER_TELEMETRY_SERVER_NAME=<YOUR_TP_ENDPOINT>" \
  -e "KONG_CLUSTER_CERT=<YOUR_CERT>" \
  -e "KONG_CLUSTER_CERT_KEY=<YOUR_KEY>" \
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" \
  -e "KONG_KONNECT_MODE=on" \
  -p 8000:8000 \
  -p 8443:8443 \
  kong/kong-gateway:3.12

# Verify container is running
docker ps --filter "ancestor=kong/kong-gateway:3.12"

# Get the container name (e.g., kong-demo-dp or auto-generated)
docker ps --format "{{.Names}}" --filter "ancestor=kong/kong-gateway:3.12"
```

**Important Notes:**
- Replace `<YOUR_CP_ENDPOINT>`, `<YOUR_TP_ENDPOINT>`, `<YOUR_CERT>`, and `<YOUR_KEY>` with actual values from Konnect
- If you didn't specify `--name`, Docker assigns a random name (e.g., `thirsty_cerf`)
- Save your container name for later use

### Step 4.3: Verify Data Plane Connection

```bash
# Test Kong is responding
curl http://localhost:8000/

# Expected: {"message":"no Route matched with those values"}
# This is correct - no routes configured yet

# Check data plane logs (replace <container-name> with yours)
docker logs <container-name> | grep -i "connected\|control plane"

# Expected to see: "successfully connected to control plane"
```

**In Konnect UI:**
1. Go to **Runtime Manager** → Your Runtime Group
2. You should see your data plane node listed as **"Connected"** with a green status



## Part 5: Configure Kong Routes

### Important: Choosing the Right Service URL

Since Kong data plane is running in **Docker** (not Kubernetes), it cannot resolve Kubernetes DNS names.

✅ **Use `host.docker.internal:3000`** - Allows Docker to reach services on your Mac
❌ **Don't use `demo-api.demo-apis.svc.cluster.local:3000`** - Will cause DNS errors

### Step 5.1: Ensure Port-Forward is Running

```bash
# Make sure port-forward is active (from Part 3)
ps aux | grep "port-forward" | grep demo-api

# If not running, start it:
kubectl port-forward -n demo-apis svc/demo-api 3000:3000 &

# Test it works:
curl http://localhost:3000/health
# Expected: {"status":"healthy",...}
```

### Step 5.2: Configure via Konnect UI

1. **Navigate to Gateway Manager** in Konnect

2. **Create Service:**
   - Click **"New Gateway Service"**
   - Name: `demo-api-service`
   - URL: `http://host.docker.internal:3000`
   - Protocol: `http`
   - Click **"Save"**

3. **Create Route:**
   - In the service, click **"New Route"**
   - Name: `demo-api-route`
   - Paths: `/api/demo`
   - Strip Path: ✅ Enable
   - Click **"Save"**

**What Strip Path Does:**
- Request: `http://localhost:8000/api/demo/api/v1/users`
- Kong strips: `/api/demo`
- Sends to backend: `/api/v1/users`

### Step 5.3: Configure via decK CLI (Alternative)

```bash
# Install decK if not already installed
brew install deck

# Export your Konnect PAT (Personal Access Token)
# Get from: Konnect UI → Account Settings → Personal Access Tokens
export DECK_KONNECT_TOKEN=kpat_your_token_here
export DECK_KONNECT_ADDR=https://us.api.konghq.com

# Create configuration file
cat > presentation-demo/kong-config/demo-api-konnect.yaml << 'EOF'
_format_version: "3.0"
_konnect:
  control_plane_name: Kong-demo

services:
  - name: demo-api-service
    url: http://host.docker.internal:3000
    routes:
      - name: demo-api-route
        paths:
          - /api/demo
        strip_path: true
EOF

# Sync configuration to Konnect
deck gateway sync demo-api-konnect.yaml \
  --konnect-token $DECK_KONNECT_TOKEN \
  --konnect-addr $DECK_KONNECT_ADDR \
  --konnect-control-plane-name Kong-demo

# Verify sync
deck gateway diff demo-api-konnect.yaml \
  --konnect-token $DECK_KONNECT_TOKEN \
  --konnect-addr $DECK_KONNECT_ADDR \
  --konnect-control-plane-name Kong-demo
```

### Step 5.4: Test Through Kong

```bash
# Test health endpoint through Kong
curl http://localhost:8000/api/demo/health
# Expected: {"status":"healthy","timestamp":"..."}

# Test users endpoint through Kong
curl http://localhost:8000/api/demo/api/v1/users
# Expected: {"success":true,"data":[...],"count":3}

# Test single user
curl http://localhost:8000/api/demo/api/v1/users/1
# Expected: {"success":true,"data":{"id":1,"name":"Alice",...}}

# Test products
curl http://localhost:8000/api/demo/api/v1/products
# Expected: {"success":true,"data":[...],"count":2}

# Test stats
curl http://localhost:8000/api/demo/api/v1/stats
# Expected: {"success":true,"data":{"totalRequests":...}}
```

✅ **Demo API is now accessible through Kong Konnect!**



## Part 6: Add Authentication

### Step 6.1: Create Consumer via Konnect UI

1. **Navigate to Gateway Manager** → **Consumers**
2. **Create Consumer:**
   - Click **"New Consumer"**
   - Username: `demo-user`
   - Click **"Save"**

3. **Add API Key Credential:**
   - In consumer details, click **"Credentials"** tab
   - Click **"New Key Auth Credential"**
   - Key: `demo-api-key-12345`
   - Click **"Save"**

### Step 6.2: Enable Key Auth Plugin

1. Go to **Plugins** → **"New Plugin"**
2. Select **"Key Authentication"**
3. Configure:
   - Scope: **Route** → Select `demo-api-route`
   - Key Names: `apikey` (default)
4. Click **"Save"**

### Step 6.3: Test Authentication

```bash
# Without API key (should fail)
curl http://localhost:8000/api/demo/api/v1/users
# Expected: {"message":"No API key found in request"}

# With API key (should succeed)
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users
# Expected: {"success":true,"data":[...],"consumer":"demo-user"}

# With invalid API key (should fail)
curl -H "apikey: wrong-key" \
  http://localhost:8000/api/demo/api/v1/users
# Expected: {"message":"Invalid authentication credentials"}
```



## Part 7: Enable Rate Limiting

### Step 7.1: Add Rate Limiting Plugin

**Via Konnect UI:**

1. Go to **Plugins** → **"New Plugin"**
2. Select **"Rate Limiting"**
3. Configure:
   - Scope: **Consumer** → Select `demo-user`
   - Minute: `10`
   - Hour: (leave empty)
   - Policy: `local`
4. Click **"Save"**

**This limits `demo-user` to 10 requests per minute**

### Step 7.2: Test Rate Limiting

```bash
# Make 11 requests rapidly
for i in {1..11}; do
  echo "Request $i:"
  curl -H "apikey: demo-api-key-12345" \
    http://localhost:8000/api/demo/api/v1/users
  echo ""
done

# Expected results:
# Requests 1-10: {"success":true,"data":[...]}
# Request 11: {"message":"API rate limit exceeded"}

# Check rate limit headers in response
curl -v -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users 2>&1 | grep -i "x-ratelimit"

# Expected headers:
# X-RateLimit-Limit-Minute: 10
# X-RateLimit-Remaining-Minute: 9
```



## Part 8: Verify Complete Setup

### Final Checklist

```bash
# 1. Check Demo API pods
kubectl get pods -n demo-apis -l app=demo-api
# Expected: 2/2 pods running

# 2. Check Demo API service
kubectl get svc demo-api -n demo-apis
# Expected: ClusterIP service on port 3000

# 3. Verify port-forward is active
curl http://localhost:3000/health
# Expected: {"status":"healthy",...}

# 4. Check Kong data plane
docker ps --filter "ancestor=kong/kong-gateway:3.12"
# Expected: 1 container running, ports 8000 and 8443

# 5. Verify Kong connection to Konnect
# - Open Konnect UI → Runtime Manager
# - Data plane should show "Connected" (green)

# 6. Check service in Konnect
# - Gateway Manager → Services → demo-api-service
# - URL should be: http://host.docker.internal:3000

# 7. Check route in Konnect
# - Gateway Manager → Routes → demo-api-route
# - Path should be: /api/demo

# 8. Test through Kong (without auth)
curl http://localhost:8000/api/demo/health
# Expected: Works (health endpoint may bypass auth)

# 9. Test through Kong (with auth)
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users
# Expected: {"success":true,"data":[...],"consumer":"demo-user"}

# 10. View analytics in Konnect
# - Navigate to Analytics in Konnect UI
# - Should see real-time metrics for requests
```

✅ **Complete setup verified!**

## Clean Up

### Remove Demo API Only

```bash
# Delete deployment
kubectl delete deployment demo-api -n demo-apis

# Delete service
kubectl delete svc demo-api -n demo-apis

# Verify removal
kubectl get all -n demo-apis -l app=demo-api
# Should return nothing
```

### Remove Namespace

```bash
# Delete entire demo-apis namespace
kubectl delete namespace demo-apis

# This removes all resources inside
```

### Remove Kong Data Plane

```bash
# Find container name
docker ps --filter "ancestor=kong/kong-gateway:3.12" --format "{{.Names}}"

# Stop and remove (replace <container-name>)
docker stop <container-name>
docker rm <container-name>

# Verify removal
docker ps -a --filter "ancestor=kong/kong-gateway:3.12"
```

### Remove from Konnect

1. **Gateway Manager** → **Services** → Delete `demo-api-service`
2. **Gateway Manager** → **Routes** → Delete `demo-api-route`
3. **Gateway Manager** → **Consumers** → Delete `demo-user`
4. **Gateway Manager** → **Plugins** → Delete rate limiting and auth plugins



## Summary

**What is accomplished:**

✅ Built Docker image for Node.js Demo API
✅ Deployed to Kubernetes with 2 replicas for HA
✅ Created service for internal cluster communication
✅ Configured health checks for automatic pod management
✅ Connected Kong data plane to Konnect control plane
✅ Configured routes to proxy traffic through Kong
✅ Added API key authentication
✅ Enabled consumer-based rate limiting
✅ Tested end-to-end from client → Kong → Demo API

**Demo API is now:**
- ✅ Running in Kubernetes (production-like)
- ✅ Proxied through Kong Konnect (API management)
- ✅ Protected with authentication (secure)
- ✅ Rate limited by consumer (controlled)
- ✅ Monitored via Konnect Analytics (observable)

**Next steps:**
- Set up Dev Portal for API documentation
- Deploy AI Router service (see `k8s_ai_service_deployment.md`)
- Configure AI plugins (AI Proxy, Prompt Guard)
