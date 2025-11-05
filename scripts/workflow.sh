#!/bin/bash

# ==============================================================================
# Kong AI Gateway - Complete Setup Workflow
# ==============================================================================
# Master script showing the complete workflow
# ==============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        Kong AI Gateway - Complete Setup Workflow              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF

echo -e "\n${CYAN}This workflow will guide you through the complete setup:${NC}\n"

echo -e "${MAGENTA}Phase 1: Setup & Basic Kong (01-04)${NC}"
echo -e "  ${BLUE}01${NC} → Install Services (Deploy to K8s)"
echo -e "  ${BLUE}02${NC} → Test Without Kong (Direct access)"
echo -e "  ${BLUE}03${NC} → Configure Kong Basic (Generate config)"
echo -e "  ${BLUE}04${NC} → Test With Kong (Verify routing)"

echo -e "\n${MAGENTA}Phase 2: Authentication (05-06)${NC}"
echo -e "  ${BLUE}05${NC} → Add Authentication (Generate config)"
echo -e "  ${BLUE}06${NC} → Test Authentication"

echo -e "\n${MAGENTA}Phase 3: AI Services (07-08)${NC}"
echo -e "  ${BLUE}07${NC} → Add AI Proxy (Generate config)"
echo -e "  ${BLUE}08${NC} → Test AI Services"

echo -e "\n${MAGENTA}Phase 4: Security (09-10)${NC}"
echo -e "  ${BLUE}09${NC} → Add AI Security (Generate config)"
echo -e "  ${BLUE}10${NC} → Test Security Features"

echo -e "\n${MAGENTA}Phase 5: Ollama Fix (11)${NC}"
echo -e "  ${BLUE}11${NC} → Fix Ollama Config (llama2 provider)"

echo -e "\n${MAGENTA}Phase 6: Redis Integration (12-13)${NC}"
echo -e "  ${BLUE}12${NC} → Add Redis-backed Rate Limiting"
echo -e "  ${BLUE}13${NC} → Test Redis Rate Limits"

echo -e "\n${MAGENTA}Phase 7: Advanced Features - Enterprise (14-17)${NC}"
echo -e "  ${BLUE}14${NC} → Add Semantic Prompt Guard ❌"
echo -e "  ${BLUE}15${NC} → Test Semantic Guard ❌"
echo -e "  ${BLUE}16${NC} → Test Redis Connection ✅"
echo -e "  ${BLUE}17${NC} → Add Semantic Cache ❌"

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${GREEN}Quick Commands:${NC}\n"
echo -e "${BLUE}# Progressive Setup (Execute in order)${NC}"
echo -e "./01-install-services.sh        # Deploy to Kubernetes"
echo -e "./02-test-without-kong.sh       # Test services directly"
echo -e "./03-configure-kong-basic.sh    # Generate + apply basic config"
echo -e "./04-test-with-kong.sh          # Test through Kong"
echo -e "./05-add-authentication.sh      # Generate + apply auth config"
echo -e "./06-test-authentication.sh     # Test authentication"
echo -e "./07-add-ai-proxy.sh            # Generate + apply AI config"
echo -e "./08-test-ai-services.sh        # Test AI services"
echo -e "./09-add-ai-security.sh         # Generate + apply security config"
echo -e "./10-test-security.sh           # Test security"
echo -e "./11-fix-ollama-config.sh       # Fix Ollama (auto-deploy)"
echo -e "./12-add-redis-plugins.sh       # Add Redis (auto-deploy)"
echo -e "./13-test-redis-rate-limits.sh  # Test Redis"

echo -e "\n${BLUE}# Enterprise features (not available)${NC}"
echo -e "./14-add-semantic-prompt-guard.sh  # ❌ Vector-based security"
echo -e "./15-test-semantic-guard.sh        # ❌ Test semantic guard"
echo -e "./16-test-redis-connection.sh      # ✅ Redis helper"
echo -e "./17-add-semantic-cache.sh         # ❌ Semantic caching"

echo -e "\n${BLUE}# Utilities${NC}"
echo -e "./cleanup.sh    # Remove everything and start fresh"
echo -e "./workflow.sh   # Show this overview"

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${GREEN}Prerequisites:${NC}"
echo -e "  ✅ Docker Desktop with Kubernetes"
echo -e "  ✅ kubectl configured"
echo -e "  ✅ Kong Konnect account"
echo -e "  ✅ decK CLI installed"
echo -e "  ⚡ Ollama installed (optional for local AI)"
echo -e "  ⚡ Gemini API key (optional for cloud AI)"

echo -e "\n${GREEN}Endpoints After Setup:${NC}"
echo -e "  • Demo API: ${CYAN}http://localhost:8000/api/demo/*${NC}"
echo -e "  • AI Router: ${CYAN}http://localhost:8000/ai/custom/*${NC}"
echo -e "  • Ollama AI: ${CYAN}http://localhost:8000/ai/kong/ollama/chat${NC}"
echo -e "  • Gemini AI: ${CYAN}http://localhost:8000/ai/kong/gemini/chat${NC}"
echo -e "  • Health: ${CYAN}http://localhost:8000/ai/health${NC} (public)"

echo -e "\n${GREEN}API Keys After Setup:${NC}"
echo -e "  • demo-user: ${YELLOW}demo-api-key-12345${NC} (10 req/min)"
echo -e "  • power-user: ${YELLOW}power-key-67890${NC} (50 req/min)"

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🎓 Learning Path${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${CYAN}📖 Recommended progression:${NC}"
echo -e "  1️⃣  Scripts 01-10: Core Kong AI Gateway setup"
echo -e "  2️⃣  Scripts 11-13: Advanced Redis integration"
echo -e "  3️⃣  Script 16: Redis connectivity testing"
echo -e "  4️⃣  Scripts 14-15, 17: Enterprise features (requires license)"
echo -e ""
echo -e "${BLUE}💡 Each script builds on the previous one - follow in order!${NC}"

echo -e "\n${BLUE}For detailed information, see: ${YELLOW}scripts/README.md${NC}"
echo -e "\n${GREEN}Ready to start? Run: ${YELLOW}./01-install-services.sh${NC}\n"
