# Kong AI Gateway Setup Scripts

Step-by-step scripts to set up and test Kong AI Gateway with Demo API and AI Router services.

## 📋 Overview

This directory contains 17 sequential scripts plus utilities for complete lifecycle management:

**Utility Scripts:**
- **cleanup.sh** - 🧹 Clean everything and start fresh
- **workflow.sh** - 📖 Show complete workflow overview
- **load-env.sh** - Load environment variables

**Core Workflow Scripts (01-17):**
1. **01-install-services.sh** - Deploy services to Kubernetes
2. **02-test-without-kong.sh** - Test APIs without Kong
3. **03-configure-kong-basic.sh** - Generate basic Kong config
4. **04-test-with-kong.sh** - Test through Kong Gateway
5. **05-add-authentication.sh** - Generate auth config
6. **06-test-authentication.sh** - Test auth & rate limiting
7. **07-add-ai-proxy.sh** - Generate AI proxy config
8. **08-test-ai-services.sh** - Test AI endpoints
9. **09-add-ai-security.sh** - Generate security config
10. **10-test-security.sh** - Test security features
11. **11-fix-ollama-config.sh** - Deploy Ollama fix (llama2 provider)
12. **12-add-redis-plugins.sh** - Add Redis-backed rate limiting
13. **13-test-redis-rate-limits.sh** - Test Redis integration
14. **14-add-semantic-prompt-guard.sh** - Add semantic security (Enterprise)
15. **15-test-semantic-guard.sh** - Test semantic guard (Enterprise)
16. **16-test-redis-connection.sh** - Test Redis connectivity
17. **17-add-semantic-cache.sh** - Add semantic cache (Enterprise)

## 🚀 Quick Start

### Fresh Start (Clean Everything)
```bash
# Reset to clean state
./cleanup.sh
```

### Recommended Workflow

**Phase 1: Setup & Basic Kong (01-04)**
```bash
# Deploy services
./01-install-services.sh

# Test services directly
./02-test-without-kong.sh

# Configure Kong basic routing
./03-configure-kong-basic.sh
# Then apply the generated config with deck

# Test through Kong
./04-test-with-kong.sh
```

**Phase 2: Authentication (05-06)**
```bash
# Add authentication & rate limiting
./05-add-authentication.sh
# Then apply the generated config with deck

# Test authentication
./06-test-authentication.sh
```

**Phase 3: AI Services (07-08)**
```bash
# Add AI Proxy for Gemini & Ollama
./07-add-ai-proxy.sh
# Then apply the generated config with deck

# Test AI services
./08-test-ai-services.sh
```

**Phase 4: Security (09-10)**
```bash
# Add AI security features
./09-add-ai-security.sh
# Then apply the generated config with deck

# Test security
./10-test-security.sh
```

**Phase 5: Ollama Fix (11)**
```bash
# Fix Ollama provider configuration
./11-fix-ollama-config.sh
# This auto-deploys with deck
```

**Phase 6: Redis Integration (12-13)**
```bash
# Add Redis-backed rate limiting
./12-add-redis-plugins.sh
# This auto-deploys with deck

# Test Redis
./13-test-redis-rate-limits.sh
```

**Phase 7: Advanced Features - Enterprise Required (14-17)**
```bash
# These require Enterprise license
./14-add-semantic-prompt-guard.sh  # ❌ Not available
./15-test-semantic-guard.sh        # ❌ Not available
./16-test-redis-connection.sh      # Helper tool
./17-add-semantic-cache.sh         # ❌ Not available
```

## 📝 Script Details

### cleanup.sh (🧹 Utility)
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
- **Interactive:** Asks for confirmation and Kong token
- **Use Case:** When you want to start completely from scratch

### workflow.sh (📖 Utility)
- **Purpose:** Display complete workflow overview
- **Shows:** All phases with descriptions
- **Includes:** Quick commands, prerequisites, endpoints
- **Use Case:** First time setup or quick reference

### load-env.sh (🔧 Helper)
- **Purpose:** Load environment variables from .env file into your current shell
- **Usage:** `source load-env.sh` (run from project root, not scripts directory)
- **When to Use:**
  - When you need environment variables in your terminal session
  - For manual testing with `curl` commands
  - Before running `deck` commands manually
- **Note:** Most scripts load `.env` automatically, so you don't need to source this first
- **Example:**
  ```bash
  cd /path/to/presentation-demo
  source scripts/load-env.sh
  # Now you can use $DEMO_API_KEY, $KONG_PROXY_URL, etc.
  curl -H "apikey: $DEMO_API_KEY" $KONG_PROXY_URL/demo/health
  ```

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

### 03-test-with-kong.sh
- Tests Demo API through Kong (port 8000)
- Tests AI Router through Kong
- Verifies routing works
- **Prerequisite**: Kong Data Plane running, config applied

### 04-test-authentication.sh
- Tests requests without API key (should fail)
- Tests with valid API keys (should succeed)
- Tests rate limiting (11 requests to trigger limit)
- Verifies rate limit headers
- **Prerequisite**: Auth config applied

### 05-test-ai-services.sh
- Tests Custom AI Router (Flask app)
- Tests Kong Native AI - Ollama
- Tests Kong Native AI - Gemini
- Compares both approaches
- **Prerequisite**: AI Proxy config applied

### 06-test-security.sh
- Tests AI Prompt Guard (blocks malicious prompts)
- Tests Response Headers (custom headers present)
- Verifies security stack
- **Prerequisite**: Security config applied

### 07-fix-ollama-config.sh
- Fixes Ollama provider configuration
- Changes from `provider: ollama` to `provider: llama2`
- Adds `llama2_format: "openai"` for compatibility
- **Output**: `../plugins/06-kong-with-ollama-fixed.yaml`
- **Deploys**: Automatically using decK
- **Prerequisite**: Ollama running with Mistral model

### 08-add-redis-plugins.sh
- Migrates rate limiting from local to Redis
- Configures Redis Cloud connection (SSL)
- Updates 6 rate-limiting plugins
- **Output**: `../plugins/07-kong-with-redis-plugins.yaml`
- **Deploys**: Automatically using decK
- **Prerequisite**: Redis Cloud credentials in .env

### 09-test-redis-rate-limits.sh
- Tests Redis-backed rate limiting
- Verifies distributed rate limits
- Tests demo-user and power-user limits
- **Prerequisite**: Redis config deployed (script 08)

### 10-add-semantic-prompt-guard.sh
- Adds vector-based prompt injection detection
- Uses Gemini embeddings + Redis vectordb
- **Status**: ❌ Requires Enterprise license
- **Output**: `../plugins/08-kong-with-semantic-guard.yaml`
- **Error**: "expected a record" validation error

### 11-test-semantic-guard.sh
- Tests semantic prompt guard functionality
- Tests various prompt injection attempts
- **Status**: ❌ Requires Enterprise license
- **Prerequisite**: Semantic guard deployed (script 10)

### 12-configure-kong-basic.sh
- Generates basic Kong configuration
- Creates services and routes only (no auth)
- **Output**: `../plugins/01-kong-basic.yaml`
- **Note**: Manual deployment required

### 13-add-authentication.sh
- Generates Kong config with Key Authentication
- Adds 2 consumers (demo-user, power-user)
- Adds rate limiting (10/min, 50/min, local policy)
- **Output**: `../plugins/02-kong-with-auth.yaml`
- **Note**: Manual deployment required

### 14-add-ai-proxy.sh
- Adds Kong Native AI services
- Configures Ollama (Mistral) with ai-proxy plugin
- Configures Gemini with ai-proxy plugin
- **Output**: `../plugins/03-kong-with-ai-proxy.yaml`
- **Prerequisites**: Ollama running, Gemini API key
- **Note**: Manual deployment required

### 15-add-ai-security.sh
- Adds AI Prompt Guard (blocks jailbreak attempts)
- Adds Response Transformer (custom headers)
- **Output**: `../plugins/04-kong-complete.yaml`
- **Note**: Manual deployment required

### 16-test-redis-connection.sh
- Tests Redis Cloud connectivity
- Verifies SSL connection
- Tests basic Redis operations
- **Prerequisite**: Redis credentials in .env

### 17-add-semantic-cache.sh
- Adds semantic caching for AI responses
- **Status**: ❌ Requires Enterprise license
- **Output**: `../plugins/05-kong-with-semantic-cache.yaml`
- **Error**: "unknown field" validation error

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

## � Using load-env.sh

The `load-env.sh` helper script loads environment variables into your shell session:

```bash
# Navigate to project root
cd /path/to/presentation-demo

# Load environment variables
source scripts/load-env.sh
# ✅ Environment variables loaded from .env

# Now you can use variables directly
echo $DEMO_API_KEY
echo $KONG_PROXY_URL

# Test APIs manually
curl -H "apikey: $DEMO_API_KEY" $KONG_PROXY_URL/demo/health

# Run deck commands
deck gateway dump \
  --konnect-token "$DECK_KONNECT_TOKEN" \
  --konnect-control-plane-name "$DECK_KONNECT_CONTROL_PLANE_NAME"
```

**Note:** You don't need to source `load-env.sh` before running other scripts - they load `.env` automatically.

## �🔧 Prerequisites

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
