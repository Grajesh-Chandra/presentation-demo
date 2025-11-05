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

echo -e "\n${CYAN}This workflow will guide you through 10 steps:${NC}\n"

echo -e "${MAGENTA}Phase 1: Service Setup${NC}"
echo -e "  ${BLUE}01${NC} → Install Services (Demo API + AI Router)"
echo -e "  ${BLUE}02${NC} → Test Without Kong (Direct K8s access)"

echo -e "\n${MAGENTA}Phase 2: Kong Basic Setup${NC}"
echo -e "  ${BLUE}03${NC} → Configure Kong Basic Routes"
echo -e "  ${BLUE}04${NC} → Test With Kong (Routing)"

echo -e "\n${MAGENTA}Phase 3: Authentication & Rate Limiting${NC}"
echo -e "  ${BLUE}05${NC} → Add Authentication & Rate Limiting"
echo -e "  ${BLUE}06${NC} → Test Authentication"

echo -e "\n${MAGENTA}Phase 4: AI Services${NC}"
echo -e "  ${BLUE}07${NC} → Add AI Proxy (Gemini & Ollama)"
echo -e "  ${BLUE}08${NC} → Test AI Services"

echo -e "\n${MAGENTA}Phase 5: AI Security${NC}"
echo -e "  ${BLUE}09${NC} → Add AI Security (Prompt Guard, etc.)"
echo -e "  ${BLUE}10${NC} → Test Security Features"

echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${GREEN}Quick Commands:${NC}\n"
echo -e "${BLUE}# Run all installation${NC}"
echo -e "./01-install-services.sh"
echo -e "./02-test-without-kong.sh"

echo -e "\n${BLUE}# Configure Kong (after deploying Data Plane)${NC}"
echo -e "./03-configure-kong-basic.sh"
echo -e "deck gateway sync --konnect-control-plane-name='Kong-Demo' \\"
echo -e "  --konnect-addr='https://in.api.konghq.com' \\"
echo -e "  --konnect-token='YOUR_TOKEN' ../plugins/01-kong-basic.yaml"
echo -e "./04-test-with-kong.sh"

echo -e "\n${BLUE}# Add authentication${NC}"
echo -e "./05-add-authentication.sh"
echo -e "# Apply config (command shown in script output)"
echo -e "./06-test-authentication.sh"

echo -e "\n${BLUE}# Add AI services${NC}"
echo -e "./07-add-ai-proxy.sh"
echo -e "# Apply config (command shown in script output)"
echo -e "./08-test-ai-services.sh"

echo -e "\n${BLUE}# Add security${NC}"
echo -e "./09-add-ai-security.sh"
echo -e "# Apply config (command shown in script output)"
echo -e "./10-test-security.sh"

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

echo -e "\n${BLUE}For detailed information, see: ${YELLOW}scripts/README.md${NC}"
echo -e "\n${GREEN}Ready to start? Run: ${YELLOW}./01-install-services.sh${NC}\n"
