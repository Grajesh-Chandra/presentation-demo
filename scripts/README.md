# Kong AI Gateway Setup Scripts

Step-by-step scripts to set up and test Kong AI Gateway with Demo API and AI Router services.

## 📋 Overview

This directory contains 11 scripts for complete lifecycle management:

**Utility Scripts:**
- **00-cleanup** - 🧹 Clean everything and start fresh
- **00-workflow** - 📖 Show complete workflow overview

**Setup & Test Scripts (01-10):**
1. **Installation** - Deploy services to Kubernetes
2. **Direct Testing** - Test APIs without Kong
3. **Basic Kong** - Configure Kong routes
4. **Kong Testing** - Test through Kong Gateway
5. **Authentication** - Add Key Auth & Rate Limiting
6. **Auth Testing** - Verify authentication works
7. **AI Proxy** - Add Gemini & Ollama AI services
8. **AI Testing** - Test AI endpoints
9. **AI Security** - Add Prompt Guard & security
10. **Security Testing** - Verify all security features

## 🚀 Quick Start

### Fresh Start (Clean Everything)
```bash
# Reset to clean state
./00-cleanup.sh
```

### Setup Process

Run scripts in order:

```bash
# Step 1: Install services
./01-install-services.sh

# Step 2: Test without Kong
./02-test-without-kong.sh

# Step 3: Generate Kong basic config
./03-configure-kong-basic.sh

# Apply Kong config (use your token)
deck gateway sync \
  --konnect-control-plane-name="Kong-Demo" \
  --konnect-addr="https://in.api.konghq.com" \
  --konnect-token="YOUR_TOKEN" \
  ../plugins/01-kong-basic.yaml

# Step 4: Test through Kong
./04-test-with-kong.sh

# Step 5: Add authentication
./05-add-authentication.sh
# (Apply config as shown in script output)

# Step 6: Test authentication
./06-test-authentication.sh

# Step 7: Add AI Proxy
./07-add-ai-proxy.sh
# (Apply config as shown in script output)

# Step 8: Test AI services
./08-test-ai-services.sh

# Step 9: Add AI security
./09-add-ai-security.sh
# (Apply config - this updates main kong-config-hybrid.yaml)

# Step 10: Test security
./10-test-security.sh
```

## 📝 Script Details

### 00-cleanup.sh (🧹 Utility)
- **Purpose:** Reset everything to start fresh
- **Removes:**
  - All Kong Konnect configurations (routes, services, plugins, consumers)
  - All Kubernetes resources (pods, services, namespace)
  - Port-forward processes
  - Generated plugin configuration files
- **Preserves:**
  - Documentation files
  - All scripts
  - Docker images (optional cleanup)
  - Kong Data Plane container (optional cleanup)
- **Interactive:** Asks for confirmation and Kong token
- **Use Case:** When you want to start completely from scratch

### 00-workflow.sh (📖 Utility)
- **Purpose:** Display complete workflow overview
- **Shows:** All 10 setup phases with descriptions
- **Includes:** Quick commands, prerequisites, endpoints
- **Use Case:** First time setup or quick reference

### 01-install-services.sh
- Cleans up old resources
- Builds Docker images
- Deploys to Kubernetes
- Sets up port forwarding
- **Output**: Services running on ports 3000 (Demo API) and 8080 (AI Router)

### 02-test-without-kong.sh
- Tests Demo API directly (users, products, stats)
- Tests AI Router directly (models, chat, stats)
- **Prerequisite**: Script 01 completed

### 03-configure-kong-basic.sh
- Generates basic Kong configuration
- Creates services and routes only (no auth)
- **Output**: `../plugins/01-kong-basic.yaml`
- **Manual Step**: Apply config via decK or Konnect UI

### 04-test-with-kong.sh
- Tests Demo API through Kong (port 8000)
- Tests AI Router through Kong
- Verifies routing works
- **Prerequisite**: Kong Data Plane running, basic config applied

### 05-add-authentication.sh
- Generates Kong config with Key Authentication
- Adds 2 consumers (demo-user, power-user)
- Adds rate limiting (10/min, 50/min)
- **Output**: `../plugins/02-kong-with-auth.yaml`
- **Manual Step**: Apply config via decK

### 06-test-authentication.sh
- Tests requests without API key (should fail)
- Tests with valid API keys (should succeed)
- Tests rate limiting (11 requests to trigger limit)
- Verifies rate limit headers
- **Prerequisite**: Auth config applied

### 07-add-ai-proxy.sh
- Adds Kong Native AI services
- Configures Ollama (Mistral) with ai-proxy plugin
- Configures Gemini (gemini-2.5-flash) with ai-proxy
- **Output**: `../plugins/03-kong-with-ai-proxy.yaml`
- **Prerequisites**: Ollama running, Mistral model pulled
- **Manual Step**: Apply config via decK

### 08-test-ai-services.sh
- Tests Custom AI Router (Flask app)
- Tests Kong Native AI - Ollama
- Tests Kong Native AI - Gemini
- Compares both approaches
- **Prerequisite**: AI Proxy config applied

### 09-add-ai-security.sh
- Adds AI Prompt Guard (blocks jailbreak attempts)
- Adds Response Transformer (custom headers)
- Adds Request Size Limiting (10MB max)
- Adds Correlation ID tracking
- **Output**: `../plugins/04-kong-complete.yaml` (complete config)
- **Manual Step**: Apply config via decK

### 10-test-security.sh
- Tests AI Prompt Guard (blocks malicious prompts)
- Tests Response Headers (custom headers present)
- Tests Request Size Limiting
- Tests Correlation ID tracking
- Verifies complete security stack
- **Prerequisite**: Security config applied

## 🔑 API Keys

**Consumers created:**
- `demo-user` → API Key: `demo-api-key-12345`
- `power-user` → API Key: `power-key-67890`

## 🌐 Endpoints

**Direct Access (Kubernetes):**
- Demo API: `http://localhost:3000`
- AI Router: `http://localhost:8080`

**Through Kong Gateway:**
- Demo API: `http://localhost:8000/api/demo/*`
- Custom AI Router: `http://localhost:8000/ai/custom/*`
- Kong AI - Ollama: `http://localhost:8000/ai/kong/ollama/chat`
- Kong AI - Gemini: `http://localhost:8000/ai/kong/gemini/chat`
- Health (public): `http://localhost:8000/ai/health`

## 📊 Rate Limits

- **demo-user**: 10 requests/minute, 100 requests/hour
- **power-user**: 50 requests/minute, 500 requests/hour

## 🛡️ Security Features

- ✅ Key Authentication
- ✅ Rate Limiting (per consumer)
- ✅ AI Prompt Guard (blocks jailbreak attempts)
- ✅ Response Transformer (custom headers)
- ✅ Request Size Limiting (10MB max)
- ✅ Correlation ID (request tracking)

## 🔧 Prerequisites

**Required:**
- Docker Desktop with Kubernetes enabled
- kubectl configured
- Kong Data Plane container running
- Kong Konnect account with Control Plane created
- decK CLI installed

**Optional (for AI features):**
- Ollama installed and running (`ollama serve`)
- Mistral model pulled (`ollama pull mistral`)
- Google Gemini API key

## 🐛 Troubleshooting

**Port forwards not working:**
```bash
pkill -f "kubectl port-forward"
kubectl port-forward -n demo-apis svc/demo-api 3000:3000 &
kubectl port-forward -n demo-apis svc/ai-router-service 8080:8080 &
```

**Kong not responding:**
```bash
docker ps --filter "ancestor=kong/kong-gateway:3.12"
docker logs <container-name>
```

**Services not deployed:**
```bash
kubectl get all -n demo-apis
kubectl describe pod <pod-name> -n demo-apis
```

**decK sync fails:**
- Verify token is valid
- Check control plane name exactly matches (case-sensitive)
- Use correct region URL (https://in.api.konghq.com for India)

## 📚 Additional Resources

- **Main Documentation**: `../README.md`
- **Demo API Guide**: `../docs/k8s_demo_api_deployment.md`
- **AI Router Guide**: `../docs/k8s_ai_service_deployment.md`
- **Plugin Evolution**: `../plugins/plugin_evolution.md`

## 🎯 Next Steps

After completing all scripts:
1. View analytics in Kong Konnect UI
2. Explore additional Kong plugins
3. Set up Dev Portal for API documentation
4. Configure additional AI providers
5. Implement custom plugins

---

**Happy Building! 🚀**
