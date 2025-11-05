# Kong Gateway Demo - AI LLM Management Platform

[![Kong Gateway](https://img.shields.io/badge/Kong-Gateway-1f4b99?style=for-the-badge&logo=kong)](https://konghq.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![AI/ML](https://img.shields.io/badge/AI%2FML-Proxy-FF6F61?style=for-the-badge)](https://konghq.com/products/kong-gateway/ai-gateway)

## 🎯 Project Overview

This repository demonstrates Kong Gateway in **DB-less mode** with **Kong Konnect** as the control plane, showcasing **TWO approaches to AI integration**:

1. **Kong Native AI Gateway** - Using Kong's built-in `ai-proxy` plugin for direct AI provider integration
2. **Custom AI Router** - Using a Flask-based microservice for custom AI routing logic

Perfect for demonstrating both Kong's native AI capabilities AND the flexibility for custom integrations.

## 📑 Table of Contents

- [🎯 Project Overview](#-project-overview)
- [🏗️ Architecture](#️-architecture)
- [✨ Key Features](#-key-features)
  - [1. 🤖 Hybrid AI Gateway Architecture](#1--hybrid-ai-gateway-architecture)
  - [2. 🔐 API Security & Management](#2--api-security--management)
  - [3. ☸️ Kubernetes Deployment](#3-️-kubernetes-deployment)
  - [4. 🎛️ Kong Konnect (Control Plane)](#4-️-kong-konnect-control-plane)
  - [5. 🚀 Demo Ready Setup](#5--demo-ready-setup)
- [📁 Repository Structure](#-repository-structure)
- [🚀 Quick Start](#-quick-start)
  - [🎬 Automated Step-by-Step Setup](#-automated-step-by-step-setup-recommended)
  - [Prerequisites](#prerequisites)
  - [System Check](#system-check)
- [📖 Step-by-Step Deployment](#-step-by-step-deployment)
  - [Step 1: Clone Repository](#step-1-clone-repository)
  - [Step 2: Deploy Demo API to Kubernetes](#step-2-deploy-demo-api-to-kubernetes)
  - [Step 3: Deploy AI Router to Kubernetes](#step-3-deploy-ai-router-to-kubernetes)
  - [Step 4: Setup Kong Gateway with Konnect](#step-4-setup-kong-gateway-with-konnect)
  - [Step 5: Configure Routes in Konnect](#step-5-configure-routes-in-konnect)
  - [Step 6: Add Authentication & Rate Limiting](#step-6-add-authentication--rate-limiting)
- [🧪 Testing & Demo Scenarios](#-testing--demo-scenarios)
  - [Test Demo API Through Kong](#test-demo-api-through-kong)
  - [Test Hybrid AI Gateway](#test-hybrid-ai-gateway)
  - [Test Rate Limiting](#test-rate-limiting)
  - [Test Authentication](#test-authentication)
- [📊 Monitoring & Analytics](#-monitoring--analytics)
  - [View Analytics in Kong Konnect](#view-analytics-in-kong-konnect)
  - [Check Kubernetes Resources](#check-kubernetes-resources)
  - [Kong Data Plane Status](#kong-data-plane-status)
- [🎯 What Makes This Demo Unique](#-what-makes-this-demo-unique)
  - [🔀 Hybrid AI Gateway Architecture](#-hybrid-ai-gateway-architecture)
  - [🎭 DB-less Architecture Benefits](#-db-less-architecture-benefits)
  - [🤖 Real AI Integration](#-real-ai-integration)
  - [☸️ Kubernetes Native](#️-kubernetes-native)
  - [🏢 Enterprise Features](#-enterprise-features)
  - [🔌 Progressive Plugin Configuration](#-progressive-plugin-configuration)
- [🔧 Troubleshooting](#-troubleshooting)
- [🧹 Clean Up](#-clean-up)
- [📚 Additional Resources](#-additional-resources)
- [🎯 Key Takeaways](#-key-takeaways)
- [📊 Quick Reference](#-quick-reference)
- [📝 License](#-license)
- [🤝 Contributing](#-contributing)
- [📧 Contact](#-contact)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│        Kong Konnect (Cloud Control Plane - DB-less)         │
│          • Configuration Management                         │
│          • Analytics & Monitoring                           │
│          • Dev Portal                                       │
└─────────────────────┬───────────────────────────────────────┘
                      │ HTTPS/mTLS
                      ▼
┌─────────────────────────────────────────────────────────────┐
│         Kong Gateway Data Plane (Docker - DB-less)          │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐     │
│  │ AI Proxy   │  │ Rate Limiting│  │  Authentication  │     │
│  │ Plugin     │  │ Plugin       │  │  Plugin          │     │
│  └────────────┘  └──────────────┘  └──────────────────┘     │
│                  localhost:8000                             │
└────────────┬────────────────────┬───────────────────────────┘
             │                    │
             ▼                    ▼
    ┌────────────────┐   ┌────────────────────┐
    │   Kubernetes   │   │    Kubernetes      │
    │   (demo-apis)  │   │   (demo-apis)      │
    │                │   │                    │
    │  ┊ AI Router   │   │  ┊ Demo API        │
    │  ┊ Service     │   │  ┊ Service         │
    │  ┊ Port: 8080  │   │  ┊ Port: 3000      │
    └───────┬────────┘   └──────────┬─────────┘
            │                       │
            ▼                       ▼
   ┌────────────────┐      ┌──────────────┐
   │ Ollama Mistral │      │ Mock Users & │
   │ Google Gemini  │      │ Products API │
   └────────────────┘      └──────────────┘
```

## ✨ Key Features

### 1. 🤖 Hybrid AI Gateway Architecture
- **Kong Native AI Gateway** (`/ai/kong/*`): Built-in ai-proxy plugin with prompt guard, token tracking
- **Custom AI Router** (`/ai/custom/*`): Flask service for custom logic and transformations
- **Ollama (Mistral)**: Self-hosted, local AI model
- **Google Gemini**: Cloud-based AI API integration
- **Side-by-Side Comparison**: Showcase both approaches in one demo

### 2. 🔐 API Security & Management
- **API Key Authentication**: Simple key-based auth
- **Consumer Management**: Track API usage per consumer
- **Rate Limiting**: Prevent API abuse with request limits
- **DB-less Mode**: No database dependencies, config via Konnect

### 3. ☸️ Kubernetes Deployment
- **Container Orchestration**: Docker Desktop Kubernetes
- **High Availability**: 2 replicas for each service
- **Health Checks**: Automatic pod management
- **ClusterIP Services**: Internal service communication

### 4. 🎛️ Kong Konnect (Control Plane)
- **Centralized Configuration**: Manage gateway via cloud UI
- **Real-time Analytics**: Monitor traffic and performance
- **GitOps Ready**: Infrastructure as Code with decK
- **Dev Portal**: API documentation and discovery

### 5. 🚀 Demo Ready Setup
- **Pre-configured Services**: AI Router + Demo API
- **Complete Documentation**: Step-by-step deployment guides
- **Test Scripts**: Easy testing and validation
- **Portal Content**: Ready-to-use API documentation

## 📁 Repository Structure

```
presentation-demo/
├── scripts/                        # 🎯 Automated Setup Scripts
│   ├── 01-install-services.sh     # Deploy to Kubernetes
│   ├── 02-test-without-kong.sh    # Test services directly
│   ├── 03-configure-kong-basic.sh # Generate basic Kong config
│   ├── 04-test-with-kong.sh       # Test through Kong
│   ├── 05-add-authentication.sh   # Generate auth config
│   ├── 06-test-authentication.sh  # Test auth & rate limiting
│   ├── 07-add-ai-proxy.sh         # Generate AI proxy config
│   ├── 08-test-ai-services.sh     # Test AI endpoints
│   ├── 09-add-ai-security.sh      # Generate security config
│   ├── 10-test-security.sh        # Test security features
│   ├── 11-fix-ollama-config.sh    # Fix Ollama provider
│   ├── 12-add-redis-plugins.sh    # Add Redis rate limiting
│   ├── 13-test-redis-rate-limits.sh # Test Redis integration
│   ├── 14-add-semantic-prompt-guard.sh # Vector security (Enterprise)
│   ├── 15-test-semantic-guard.sh  # Test semantic guard (Enterprise)
│   ├── 16-test-redis-connection.sh # Test Redis
│   ├── 17-add-semantic-cache.sh   # Semantic cache (Enterprise)
│   ├── cleanup.sh                 # 🧹 Clean everything
│   ├── workflow.sh                # 📖 Workflow overview
│   ├── load-env.sh                # Load environment variables
│   └── README.md                   # Detailed script guide
│
├── plugins/                        # 🔌 Kong Configuration Files
│   ├── 01-kong-basic.yaml         # Basic routing
│   ├── 02-kong-with-auth.yaml     # + Authentication
│   ├── 03-kong-with-ai-proxy.yaml # + AI Services
│   ├── 04-kong-complete.yaml      # + Security (Production)
│   ├── 06-kong-with-ollama-fixed.yaml # + Fixed Ollama (llama2)
│   ├── 07-kong-with-redis-plugins.yaml # + Redis rate limiting
│   ├── 08-kong-with-semantic-guard.yaml # + Vector-based security
│   └── README.md                   # Plugin overview
│
├── kubernetes/                      # Kubernetes configurations
│   └── namespace.yaml              # demo-apis namespace
│
├── ai-services/                    # AI Router Service
│   └── ai-router/
│       ├── app.py                  # Flask app (Ollama + Gemini)
│       ├── requirements.txt        # Python dependencies
│       ├── Dockerfile              # Container build
│       └── deployment.yaml         # K8s deployment + service
│
├── api-examples/                   # Demo API Service
│   └── nodejs-api/
│       ├── server.js               # Express.js app
│       ├── package.json            # Node dependencies
│       ├── Dockerfile              # Container build
│       ├── deployment.yaml         # K8s deployment + service
│       ├── openapi.yaml            # API specification
│       └── healthcheck.js          # Health endpoint
│
├── docs/                           # Deployment Documentation
│   ├── k8s_demo_api_deployment.md # Deploy Node.js API guide
│   └── k8s_ai_service_deployment.md # Deploy AI Router guide
│
├── portal/                         # Kong Dev Portal Content
│   ├── README.md                   # Portal overview
│   ├── getting-started.md          # Getting started guide
│   ├── authentication-guide.md     # Auth documentation
│   └── snippets.md                 # Code examples
│
├── LICENSE                         # MIT License
└── README.md                       # This file (SINGLE SOURCE OF TRUTH)
```

## 🚀 Quick Start

### 🎬 Automated Step-by-Step Setup (Recommended)

**1. Start with the workflow overview:**

```bash
cd scripts
./workflow.sh  # Shows complete workflow, prerequisites, and quick commands
```

**2. Progressive Setup (01-13):**

```bash
# Phase 1: Setup & Basic Kong
./01-install-services.sh        # Deploy to Kubernetes
./02-test-without-kong.sh       # Test services directly
./03-configure-kong-basic.sh    # Generate basic config + apply with deck
./04-test-with-kong.sh          # Test through Kong

# Phase 2: Authentication
./05-add-authentication.sh      # Generate auth config + apply with deck
./06-test-authentication.sh     # Test auth & rate limiting

# Phase 3: AI Services
./07-add-ai-proxy.sh            # Generate AI config + apply with deck
./08-test-ai-services.sh        # Test AI endpoints

# Phase 4: Security
./09-add-ai-security.sh         # Generate security config + apply with deck
./10-test-security.sh           # Test security features

# Phase 5: Ollama Fix & Redis
./11-fix-ollama-config.sh       # Fix Ollama (auto-deploys)
./12-add-redis-plugins.sh       # Add Redis (auto-deploys)
./13-test-redis-rate-limits.sh  # Test Redis
```

**3. Advanced Features (14-17) - Enterprise Required:**

```bash
./14-add-semantic-prompt-guard.sh # ❌ Vector-based security
./15-test-semantic-guard.sh       # ❌ Test semantic guard
./16-test-redis-connection.sh     # ✅ Helper tool
./17-add-semantic-cache.sh        # ❌ Semantic caching
```

**4. Reset everything when needed:**

```bash
./cleanup.sh  # Removes all Kong configs, K8s resources, port-forwards
```

### 📚 Additional Documentation

- **[scripts/README.md](scripts/README.md)** - Detailed script documentation and troubleshooting
- **[plugins/README.md](plugins/README.md)** - Plugin configuration overview
- **[plugins/plugin_evolution.md](plugins/plugin_evolution.md)** - Step-by-step Kong config evolution

### Prerequisites

**Required:**
- ✅ Docker Desktop with Kubernetes enabled
- ✅ kubectl (comes with Docker Desktop)
- ✅ Kong Konnect account ([Free signup](https://cloud.konghq.com/signup))
- ✅ Kong Data Plane container running (Docker)
- ✅ `deck` CLI for GitOps ([Install guide](https://docs.konghq.com/deck/latest/installation/))

**Optional (for AI features):**
- ⚡ Ollama installed (`brew install ollama`)
- ⚡ Mistral model pulled (`ollama pull mistral`)
- ⚡ Google Gemini API key ([Get key](https://ai.google.dev/))

### System Check

```bash
# Verify Docker & Kubernetes
docker --version
kubectl version --client
kubectl cluster-info

# Check if Kubernetes is running
kubectl get nodes
# Expected: Docker Desktop node showing Ready
```

## 📖 Step-by-Step Deployment

### Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/Grajesh-Chandra/presentation-demo.git
cd presentation-demo
```

### Step 2: Deploy Demo API to Kubernetes

**Complete guide with screenshots: [`docs/k8s_demo_api_deployment.md`](docs/k8s_demo_api_deployment.md)**

```bash
# Build Docker image
cd api-examples/nodejs-api
docker build -t demo-api:latest .

# Deploy to Kubernetes
cd ../..
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f api-examples/nodejs-api/deployment.yaml

# Verify deployment
kubectl get pods -n demo-apis -l app=demo-api
# Expected: 2/2 pods running

# Port forward for testing
kubectl port-forward -n demo-apis svc/demo-api 3000:3000 &

# Test API
curl http://localhost:3000/health
curl http://localhost:3000/api/v1/users
```

### Step 3: Deploy AI Router to Kubernetes

**Complete guide with screenshots: [`docs/k8s_ai_service_deployment.md`](docs/k8s_ai_service_deployment.md)**

```bash
# Build Docker image
cd ai-services/ai-router
docker build -t ai-router:latest .

# Deploy to Kubernetes
cd ../..
kubectl apply -f ai-services/ai-router/deployment.yaml

# Verify deployment
kubectl get pods -n demo-apis -l app=ai-router
# Expected: 2/2 pods running (may take 1-2 minutes)

# Port forward for testing
kubectl port-forward -n demo-apis svc/ai-router-service 8080:8080 &

# Test AI Router
curl http://localhost:8080/health
curl http://localhost:8080/models
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello AI","model":"mistral","provider":"ollama"}'
```

### Step 4: Setup Kong Gateway with Konnect

**DB-less mode with cloud control plane**

```bash
# 1. Sign up for Kong Konnect (free)
open https://cloud.konghq.com/signup

# 2. Create Runtime Group
# - Name: "Kong-demo"
# - Click "New Data Plane Node"
# - Copy connection details

# 3. Run Kong Data Plane in Docker
docker run -d \
  --name kong-demo-dp \
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

# 4. Verify connection
curl http://localhost:8000/
# Expected: {"message":"no Route matched with those values"}

# Check Konnect UI - Data Plane should show "Connected" (green)
```

### Step 5: Configure Routes in Konnect

**Via Konnect UI:**

1. **Create Demo API Service:**
   - Gateway Manager → New Service
   - Name: `demo-api-service`
   - URL: `http://host.docker.internal:3000`
   - Save

2. **Create Demo API Route:**
   - In service → New Route
   - Name: `demo-api-route`
   - Paths: `/api/demo`
   - Strip Path: ✅ Enable
   - Save

3. **Create AI Router Service:**
   - Gateway Manager → New Service
   - Name: `ai-router-service`
   - URL: `http://host.docker.internal:8080`
   - Save

4. **Create AI Router Route:**
   - In service → New Route
   - Name: `ai-router-route`
   - Paths: `/ai`
   - Strip Path: ❌ Disable
   - Save

### Step 6: Add Authentication & Rate Limiting

```bash
# Test through Kong (will work without auth initially)
curl http://localhost:8000/api/demo/api/v1/users
curl http://localhost:8000/ai/health
```

**Add via Konnect UI:**

1. **Create Consumer:**
   - Gateway Manager → Consumers → New Consumer
   - Username: `demo-user`
   - Credentials → New Key Auth Credential
   - Key: `demo-api-key-12345`

2. **Enable Key Authentication:**
   - Plugins → New Plugin → Key Authentication
   - Scope: Route → Select both routes
   - Save

3. **Add Rate Limiting:**
   - Plugins → New Plugin → Rate Limiting
   - Scope: Consumer → `demo-user`
   - Minute: `10`
   - Save

```bash
# Test with authentication
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users

curl -H "apikey: demo-api-key-12345" \
  -X POST http://localhost:8000/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Test","model":"mistral","provider":"ollama"}'
```

## 🧪 Testing & Demo Scenarios

### Test Demo API Through Kong

```bash
# Health check
curl http://localhost:8000/api/demo/health

# List users (with auth)
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users

# Get single user
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users/1

# List products
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/products

# API statistics
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/stats
```

### Test Hybrid AI Gateway

**🎯 Kong Native AI Gateway (Recommended Approach)**

```bash
# Chat with Ollama via Kong's ai-proxy plugin
curl -X POST http://localhost:8000/ai/kong/ollama/chat \
  -H "apikey: demo-api-key-12345" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "Explain API management in 2 sentences"
      }
    ]
  }'
# ✅ Native Kong AI Gateway
# ✅ Built-in prompt guard
# ✅ Automatic token tracking
# ✅ OpenAI-compatible format

# Chat with Gemini via Kong's ai-proxy plugin
curl -X POST http://localhost:8000/ai/kong/gemini/chat \
  -H "apikey: demo-api-key-12345" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "What is Kong Gateway?"
      }
    ]
  }'
```

**🔧 Custom AI Router (Flexible Approach)**

```bash
# Chat with Ollama via Custom Router
curl -X POST http://localhost:8000/ai/custom/chat \
  -H "apikey: demo-api-key-12345" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Explain API management in 2 sentences",
    "provider": "ollama",
    "model": "mistral"
  }'
# ✅ Custom request format
# ✅ Custom business logic
# ✅ Flexible transformations

# Chat with Gemini via Custom Router
curl -X POST http://localhost:8000/ai/custom/chat \
  -H "apikey: demo-api-key-12345" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What is Kong Gateway?",
    "provider": "gemini",
    "model": "gemini-pro"
  }'

# List available models
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/ai/custom/models
```

**📊 Compare Both Approaches**

Both approaches are documented in the scripts. See [`scripts/README.md`](scripts/README.md) for detailed comparison.

### Test Rate Limiting

```bash
# Make 11 requests rapidly (limit is 10/minute)
for i in {1..11}; do
  echo "Request $i:"
  curl -H "apikey: demo-api-key-12345" \
    http://localhost:8000/api/demo/api/v1/users
  echo ""
done

# Expected: First 10 succeed, 11th gets rate limited
# Response: {"message":"API rate limit exceeded"}
```

### Test Authentication

```bash
# Without API key (should fail)
curl http://localhost:8000/api/demo/api/v1/users
# Expected: {"message":"No API key found in request"}

# With wrong API key (should fail)
curl -H "apikey: wrong-key-123" \
  http://localhost:8000/api/demo/api/v1/users
# Expected: {"message":"Invalid authentication credentials"}

# With correct API key (should succeed)
curl -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/api/v1/users
# Expected: {"success":true,"data":[...],"consumer":"demo-user"}
```

## � Monitoring & Analytics

### View Analytics in Kong Konnect

1. **Navigate to Analytics** in Konnect UI
2. **View Metrics:**
   - Total Requests
   - Success/Error Rates
   - Latency (P50, P95, P99)
   - Traffic by Consumer
   - Traffic by Route/Service

3. **Filter by:**
   - Time range (Last hour, 24 hours, 7 days)
   - Consumer: `demo-user`
   - Route: `demo-api-route` or `ai-router-route`
   - Service: `demo-api-service` or `ai-router-service`

### Check Kubernetes Resources

```bash
# View all resources in demo-apis namespace
kubectl get all -n demo-apis

# Check pod status
kubectl get pods -n demo-apis

# View pod logs
kubectl logs -n demo-apis -l app=demo-api --tail=50
kubectl logs -n demo-apis -l app=ai-router --tail=50

# Describe deployment
kubectl describe deployment demo-api -n demo-apis
kubectl describe deployment ai-router -n demo-apis

# Check service endpoints
kubectl get endpoints -n demo-apis

# View resource usage
kubectl top pods -n demo-apis
```

### Kong Data Plane Status

```bash
# Check Kong container
docker ps --filter "name=kong-demo-dp"

# View Kong logs
docker logs kong-demo-dp --tail=50

# Check Kong status endpoint (if exposed)
curl http://localhost:8001/status
# Note: Admin API may not be exposed in DB-less mode
```

## 🎯 What Makes This Demo Unique

### 🔀 Hybrid AI Gateway Architecture
- **Kong Native AI Gateway**: Built-in `ai-proxy` plugin (production approach)
  - Routes: `/ai/kong/ollama/chat`, `/ai/kong/gemini/chat`
  - Native prompt guard, token tracking, OpenAI-compatible format
- **Custom AI Router**: Flask microservice (flexible approach)
  - Routes: `/ai/custom/chat`, `/ai/health`
  - Custom request format, business logic, transformations
- **Side-by-Side Comparison**: Both approaches working simultaneously
- **Real-World Scenarios**: Learn when to use each approach

### 🎭 DB-less Architecture Benefits
- **No Database Required**: Kong runs in DB-less mode (no PostgreSQL/Cassandra)
- **Configuration via Konnect**: All config managed through cloud UI or decK CLI
- **Declarative Config**: GitOps-ready with version-controlled YAML files
- **Fast Startup**: No database initialization or migrations needed
- **Stateless**: Easy to scale horizontally

### 🤖 Real AI Integration
- **Ollama (Mistral)**: Local, self-hosted AI model on localhost:11434
- **Google Gemini**: Cloud-based AI API (gemini-2.5-flash model)
- **Production Ready**: Real API calls to both providers
- **OpenAI Compatible**: Uses OpenAI format for consistency
- **Fixed Configuration**: llama2_format set to "openai" for compatibility

### ☸️ Kubernetes Native
- **Container Orchestration**: Services run in Docker Desktop Kubernetes
- **High Availability**: 2 replicas per service (demo-api, ai-router)
- **Health Checks**: Automatic pod restart and management
- **Service Discovery**: ClusterIP services for internal communication
- **Port Forwarding**: Easy local access (3000, 8080, 8000)

### 🏢 Enterprise Features
- **Kong Konnect**: Cloud control plane (India region)
- **API Management**: Authentication (key-auth), rate limiting (10/50 req/min)
- **AI Security**: Prompt guard (blocks jailbreak/DAN attacks)
- **Analytics**: Real-time monitoring, traffic metrics, latency tracking
- **Request Tracking**: Correlation IDs, custom headers
- **Dev Portal**: API documentation and discovery

### 🔌 Progressive Plugin Configuration
| Stage | File | Services | Routes | Plugins | Features |
|-------|------|----------|--------|---------|----------|
| 1. Basic | `01-kong-basic.yaml` | 2 | 2 | 0 | Basic routing test |
| 2. Auth | `02-kong-with-auth.yaml` | 2 | 2 | 5 | Authentication & rate limiting (local) |
| 3. AI | `03-kong-with-ai-proxy.yaml` | 4 | 5 | 11 | AI services (Ollama + Gemini) |
| 4. Complete | `04-kong-complete.yaml` | 4 | 5 | 14 | Production security |
| 5. Ollama Fixed | `06-kong-with-ollama-fixed.yaml` | 4 | 5 | 16 | Fixed Ollama provider (llama2) |
| 6. Redis | `07-kong-with-redis-plugins.yaml` | 4 | 5 | 14 | Redis-backed rate limiting |
| 7. Semantic Guard | `08-kong-with-semantic-guard.yaml` | 4 | 5 | 15 | Vector-based prompt injection detection |


## 🔧 Troubleshooting

### Kong Returns 503 Service Unavailable

**Cause:** Port-forwards not running or services not accessible

**Solution:**
```bash
# 1. Check if port-forwards are running
ps aux | grep "port-forward"

# 2. Restart port-forwards
kubectl port-forward -n demo-apis svc/demo-api 3000:3000 &
kubectl port-forward -n demo-apis svc/ai-router 8080:8080 &

# 3. Verify services work directly
curl http://localhost:3000/health
curl http://localhost:8080/health

# 4. Check Kong can reach services (uses host.docker.internal)
docker exec kong-demo-dp curl http://host.docker.internal:3000/health
```

### Pods Not Starting

**Cause:** Image issues, resource constraints, or configuration errors

**Solution:**
```bash
# 1. Check pod status
kubectl get pods -n demo-apis

# 2. View pod logs
kubectl logs -n demo-apis -l app=demo-api --tail=50
kubectl logs -n demo-apis -l app=ai-router --tail=50

# 3. Describe pod for events
kubectl describe pod -n demo-apis -l app=demo-api

# 4. Common fixes:
# - Image pull errors: Rebuild image (docker build -t demo-api:latest .)
# - CrashLoopBackOff: Check application logs for errors
# - Pending: Check resource limits and node capacity
```

### Kong Data Plane Not Connected

**Cause:** Wrong certificates or control plane endpoint

**Solution:**
```bash
# 1. Check Kong container logs
docker logs kong-demo-dp --tail=100

# 2. Check container is running
docker ps | grep kong

# 3. Verify Konnect UI shows "Connected" (green)
# If not, re-deploy with correct CP/TP endpoints and certificates from Konnect UI

# 4. Test Kong responds
curl http://localhost:8000/
# Expected: {"message":"no Route matched with those values"}
```

### Ollama AI Transformation Errors

**Cause:** Wrong llama2_format setting

**Solution:**
```bash
# Ensure llama2_format is set to "openai" (not "ollama")
# This is already fixed in scripts/07-add-ai-proxy.sh and scripts/09-add-ai-security.sh

# Check your plugin configuration:
grep -A 5 "llama2_format" plugins/03-kong-with-ai-proxy.yaml
# Should show: llama2_format: openai

# If wrong, regenerate config:
cd scripts
./07-add-ai-proxy.sh
# Then reapply with decK
```

### Rate Limit Issues

**Cause:** Exceeded 10 requests/minute (demo-user) or 50 requests/minute (power-user)

**Solution:**
```bash
# 1. Check rate limit headers
curl -i -H "apikey: demo-api-key-12345" \
  http://localhost:8000/api/demo/users
# Look for: X-RateLimit-Remaining-Minute

# 2. Use power-user for heavy testing
curl -H "apikey: power-key-67890" \
  http://localhost:8000/api/demo/users

# 3. Wait 1 minute for limits to reset
```

### AI Services Not Working

**Cause:** Ollama not running or Gemini API key missing/invalid

**Solution:**
```bash
# For Ollama:
# 1. Start Ollama service
ollama serve

# 2. Check Mistral model is installed
ollama list
# If not: ollama pull mistral

# 3. Test Ollama directly
curl http://localhost:11434/api/generate \
  -d '{"model":"mistral","prompt":"Hello"}'

# For Gemini:
# 1. Verify API key in plugin config
grep "x-goog-api-key" plugins/03-kong-with-ai-proxy.yaml

# 2. Test Gemini API key directly
curl https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=YOUR_KEY \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
```

### decK Sync Errors

**Cause:** Wrong path, missing token, or invalid configuration

**Solution:**
```bash
# 1. Ensure you're in /scripts directory
cd /Users/admin/Documents/presentation-demo/scripts

# 2. Use correct relative path (../ not needed if in project root)
deck gateway sync \
  --konnect-control-plane-name='Kong-Demo' \
  --konnect-addr='https://in.api.konghq.com' \
  --konnect-token='YOUR_TOKEN' \
  ../plugins/01-kong-basic.yaml

# 3. Validate config file first
deck gateway validate ../plugins/01-kong-basic.yaml

# 4. Check Kong Konnect token is valid
# Get from: https://cloud.konghq.com/global/account/tokens
```

## 🧹 Clean Up

### 🎯 Automated Cleanup (Recommended)

```bash
cd scripts
./00-cleanup.sh
```

**This script will:**
- ✅ Remove all Kong Konnect configurations (applies empty config)
- ✅ Stop and remove Kong Docker containers
- ✅ Delete Kubernetes resources (demo-apis namespace)
- ✅ Kill port-forward processes
- ✅ Remove generated plugin files (preserves docs)
- ✅ Interactive confirmation before each step

**Note:** This preserves your Kong-Demo control plane in Konnect UI (only clears configurations)

### 🔧 Manual Cleanup (If Needed)

<details>
<summary>Click to expand manual cleanup steps</summary>

#### Stop Port Forwards
```bash
# Find and kill port-forward processes
ps aux | grep "port-forward" | grep -v grep | awk '{print $2}' | xargs kill
```

#### Remove Kubernetes Resources
```bash
# Delete deployments
kubectl delete -f api-examples/nodejs-api/deployment.yaml
kubectl delete -f ai-services/ai-router/deployment.yaml

# Or delete entire namespace (removes everything)
kubectl delete namespace demo-apis
```

#### Stop Kong Data Plane
```bash
# Stop and remove Kong container(s)
docker ps --filter "ancestor=kong/kong-gateway" --format "{{.ID}}" | xargs docker stop
docker ps -a --filter "ancestor=kong/kong-gateway" --format "{{.ID}}" | xargs docker rm
```

#### Clean Up Konnect (via UI)
1. Gateway Manager → Services → Delete all services
2. Gateway Manager → Routes → Delete all routes
3. Gateway Manager → Consumers → Delete all consumers
4. Gateway Manager → Plugins → Delete all plugins

#### Remove Generated Config Files
```bash
cd plugins
rm -f 01-kong-basic.yaml 02-kong-with-auth.yaml 03-kong-with-ai-proxy.yaml 04-kong-complete.yaml
```

</details>

## 📚 Additional Resources

### Documentation
- **[Demo API Deployment Guide](docs/k8s_demo_api_deployment.md)** - Complete Node.js API setup
- **[AI Router Deployment Guide](docs/k8s_ai_service_deployment.md)** - Complete AI service setup
- **[Scripts Reference](scripts/README.md)** - All automation scripts
- **[Plugin Evolution](plugins/plugin_evolution.md)** - Plugin configuration progression

### Kong Resources
- **[Kong Konnect](https://cloud.konghq.com)** - Cloud control plane
- **[Kong Docs](https://docs.konghq.com)** - Official documentation
- **[Kong Community](https://discuss.konghq.com)** - Community forum
- **[decK](https://docs.konghq.com/deck/)** - GitOps configuration tool

### AI Providers
- **[Ollama](https://ollama.ai)** - Local AI models
- **[Google Gemini](https://ai.google.dev)** - Google's AI API
- **[Mistral AI](https://mistral.ai)** - Mistral models

## 🎯 Key Takeaways

- ✅ **Hybrid AI Architecture**: Kong Native AI Gateway + Custom AI Router side-by-side
- ✅ **DB-less Mode**: Kong Gateway without database dependencies
- ✅ **Cloud Control Plane**: Configuration managed via Kong Konnect (India region)
- ✅ **Kubernetes Native**: Containerized services with high availability (2 replicas each)
- ✅ **Real AI Integration**: Ollama (local Mistral) + Google Gemini (cloud)
- ✅ **Progressive Setup**: 4-stage configuration evolution (basic → auth → AI → security)
- ✅ **Enterprise Security**: API keys, rate limiting (10/50 req/min), AI prompt guard
- ✅ **Production Ready**: Complete security stack, request tracking, size limits
- ✅ **GitOps Ready**: All configurations version-controlled in `/plugins`
- ✅ **Automated Workflow**: 10-step scripts + comprehensive cleanup
- ✅ **Observability**: Analytics, monitoring, correlation IDs, custom headers

## 📊 Quick Reference

### API Keys
| Consumer | API Key | Rate Limit | Use Case |
|----------|---------|------------|----------|
| demo-user | `demo-api-key-12345` | 10/min | Testing, demos |
| power-user | `power-key-67890` | 50/min | Heavy testing |

### Endpoints
| Endpoint | Auth | Description |
|----------|------|-------------|
| `http://localhost:8000/api/demo/*` | ✅ Required | Demo API (users, products, stats) |
| `http://localhost:8000/ai/custom/chat` | ✅ Required | Custom AI Router (Flask) |
| `http://localhost:8000/ai/health` | ❌ Public | Health check (no auth) |
| `http://localhost:8000/ai/kong/ollama/chat` | ✅ Required | Kong Native AI (Ollama/Mistral) |
| `http://localhost:8000/ai/kong/gemini/chat` | ✅ Required | Kong Native AI (Google Gemini) |

### Ports
- **3000**: Demo API (Node.js/Express)
- **8080**: AI Router (Python/Flask)
- **8000**: Kong Gateway Data Plane
- **11434**: Ollama (local AI)

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

This is a demo project. Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📧 Contact

For questions or support:
- **Repository**: https://github.com/Grajesh-Chandra/presentation-demo
- **Kong Documentation**: https://docs.konghq.com
- **Kong Community**: https://discuss.konghq.com



**Built with Kong Gateway + Konnect**
*Showcasing Enterprise-Grade API & AI Management in DB-less Mode*
