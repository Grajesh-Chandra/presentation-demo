#!/bin/bash

# ==============================================================================
# 00 - Clean Up Everything (Reset to Fresh Start)
# ==============================================================================
# Removes all Kong configurations, Kubernetes resources, and generated files
# Use this to start from scratch
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_warning() {
    echo -e "${RED}⚠️  WARNING: This will DELETE EVERYTHING! ⚠️${NC}"
    echo -e "${YELLOW}This script will remove:${NC}"
    echo -e "  • All Kong Gateway configurations (routes, services, plugins, consumers)"
    echo -e "  • All Kubernetes resources (demo-api, ai-router)"
    echo -e "  • Generated plugin configuration files"
    echo -e "  • Port-forward processes"
    echo -e ""
}

cd "$(dirname "$0")/.." || exit 1

print_header "🧹 CLEAN UP EVERYTHING - RESET TO FRESH START"

print_warning

echo -e "${YELLOW}Are you sure you want to continue? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${GREEN}Cleanup cancelled.${NC}"
    exit 0
fi

echo -e "\n${MAGENTA}Starting cleanup process...${NC}\n"

# ==============================================================================
# 1. CLEAN KONG KONNECT (CONTROL PLANE)
# ==============================================================================

print_header "1. CLEANING KONG KONNECT (CONTROL PLANE)"

echo -e "${YELLOW}Enter your Kong Konnect token (or press Enter to skip Kong cleanup):${NC}"
read -r KONG_TOKEN

if [ -n "$KONG_TOKEN" ]; then
    echo -e "${BLUE}Cleaning Kong configuration...${NC}"

    # Create empty configuration
    cat > /tmp/kong-empty.yaml << 'EOF'
_format_version: "3.0"
_konnect:
  control_plane_name: Kong-Demo

services: []
consumers: []
plugins: []
EOF

    echo -e "${CYAN}Applying empty configuration to remove all resources...${NC}"
    deck gateway sync \
        --konnect-control-plane-name='Kong-Demo' \
        --konnect-addr='https://in.api.konghq.com' \
        --konnect-token="$KONG_TOKEN" \
        /tmp/kong-empty.yaml || echo -e "${YELLOW}Warning: Could not clean Kong config (might not exist)${NC}"

    rm -f /tmp/kong-empty.yaml
    echo -e "${GREEN}✅ Kong Konnect cleaned${NC}"
else
    echo -e "${YELLOW}⏭️  Skipping Kong Konnect cleanup${NC}"
fi

# ==============================================================================
# 2. KILL PORT-FORWARD PROCESSES
# ==============================================================================

print_header "2. STOPPING PORT-FORWARD PROCESSES"

echo -e "${BLUE}Finding port-forward processes...${NC}"
PORT_FORWARDS=$(ps aux | grep "port-forward" | grep -v grep | awk '{print $2}')

if [ -n "$PORT_FORWARDS" ]; then
    echo "$PORT_FORWARDS" | while read -r pid; do
        echo -e "  Killing process $pid"
        kill "$pid" 2>/dev/null || true
    done
    echo -e "${GREEN}✅ Port-forward processes stopped${NC}"
else
    echo -e "${YELLOW}⏭️  No port-forward processes found${NC}"
fi

# ==============================================================================
# 3. DELETE KUBERNETES RESOURCES
# ==============================================================================

print_header "3. CLEANING KUBERNETES RESOURCES"

echo -e "${BLUE}Checking for Kubernetes resources in demo-apis namespace...${NC}"

if kubectl get namespace demo-apis >/dev/null 2>&1; then
    echo -e "${CYAN}Deleting Demo API deployment...${NC}"
    kubectl delete -f api-examples/nodejs-api/deployment.yaml --ignore-not-found=true || true

    echo -e "${CYAN}Deleting AI Router deployment...${NC}"
    kubectl delete -f ai-services/ai-router/deployment.yaml --ignore-not-found=true || true

    echo -e "${CYAN}Deleting namespace...${NC}"
    kubectl delete namespace demo-apis --ignore-not-found=true || true

    echo -e "${CYAN}Waiting for namespace deletion...${NC}"
    kubectl wait --for=delete namespace/demo-apis --timeout=60s 2>/dev/null || true

    echo -e "${GREEN}✅ Kubernetes resources deleted${NC}"
else
    echo -e "${YELLOW}⏭️  demo-apis namespace not found${NC}"
fi

# ==============================================================================
# 4. DELETE GENERATED PLUGIN FILES
# ==============================================================================

print_header "4. CLEANING GENERATED PLUGIN FILES"

echo -e "${BLUE}Removing generated Kong configuration files...${NC}"

if [ -d "plugins" ]; then
    rm -f plugins/01-kong-basic.yaml
    rm -f plugins/02-kong-with-auth.yaml
    rm -f plugins/03-kong-with-ai-proxy.yaml
    rm -f plugins/04-kong-complete.yaml

    # Keep documentation files
    echo -e "${CYAN}Keeping documentation files (README.md, plugin_evolution.md)${NC}"

    echo -e "${GREEN}✅ Generated plugin files removed${NC}"
else
    echo -e "${YELLOW}⏭️  plugins directory not found${NC}"
fi

# ==============================================================================
# 5. STOP AND REMOVE KONG DATA PLANE CONTAINER
# ==============================================================================

print_header "5. CLEANING KONG DATA PLANE (DOCKER CONTAINER)"

echo -e "${BLUE}Checking for Kong Data Plane Docker containers...${NC}"

# Find all Kong containers (by image name)
KONG_CONTAINERS=$(docker ps -a --filter "ancestor=kong/kong-gateway:3.12" --format "{{.Names}}" 2>/dev/null || echo "")

if [ -z "$KONG_CONTAINERS" ]; then
    # Try to find by common names
    KONG_CONTAINERS=$(docker ps -a --format "{{.Names}}" | grep -i "kong" || echo "")
fi

if [ -n "$KONG_CONTAINERS" ]; then
    echo "$KONG_CONTAINERS" | while read -r container; do
        if [ -n "$container" ]; then
            echo -e "${CYAN}Found Kong container: $container${NC}"

            # Stop the container if running
            if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
                echo -e "${CYAN}  Stopping container...${NC}"
                docker stop "$container" 2>/dev/null || true
            fi

            # Remove the container
            echo -e "${CYAN}  Removing container...${NC}"
            docker rm "$container" 2>/dev/null || true

            echo -e "${GREEN}  ✅ Container removed${NC}"
        fi
    done
else
    echo -e "${YELLOW}⏭️  No Kong Data Plane containers found${NC}"
fi

# ==============================================================================
# 6. VERIFY CLEANUP
# ==============================================================================

print_header "6. VERIFYING CLEANUP"

echo -e "${BLUE}Checking cleanup status...${NC}\n"

# Check Kubernetes
echo -e "${CYAN}Kubernetes Status:${NC}"
if kubectl get namespace demo-apis >/dev/null 2>&1; then
    echo -e "  ${RED}❌ demo-apis namespace still exists${NC}"
else
    echo -e "  ${GREEN}✅ demo-apis namespace removed${NC}"
fi

# Check port-forwards
echo -e "\n${CYAN}Port-Forward Status:${NC}"
PORT_FORWARDS=$(ps aux | grep "port-forward" | grep -v grep | wc -l | tr -d ' ')
if [ "$PORT_FORWARDS" -eq 0 ]; then
    echo -e "  ${GREEN}✅ No port-forward processes running${NC}"
else
    echo -e "  ${YELLOW}⚠️  $PORT_FORWARDS port-forward processes still running${NC}"
fi

# Check plugin files
echo -e "\n${CYAN}Plugin Files Status:${NC}"
PLUGIN_COUNT=$(find plugins -name "*.yaml" ! -name "README.md" ! -name "plugin_evolution.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PLUGIN_COUNT" -eq 0 ]; then
    echo -e "  ${GREEN}✅ No generated plugin files${NC}"
else
    echo -e "  ${YELLOW}⚠️  $PLUGIN_COUNT plugin files remain${NC}"
fi

# Check Kong Docker containers
echo -e "\n${CYAN}Kong Docker Container Status:${NC}"
REMAINING_KONG=$(docker ps -a --filter "ancestor=kong/kong-gateway:3.12" --format "{{.Names}}" 2>/dev/null | wc -l | tr -d ' ')
if [ "$REMAINING_KONG" -eq 0 ]; then
    echo -e "  ${GREEN}✅ All Kong containers removed${NC}"
else
    echo -e "  ${YELLOW}⚠️  $REMAINING_KONG Kong container(s) still exist${NC}"
    docker ps -a --filter "ancestor=kong/kong-gateway:3.12" --format "  - {{.Names}}"
fi

# Check Kong Gateway accessibility
echo -e "\n${CYAN}Kong Gateway Accessibility:${NC}"
if curl -s http://localhost:8000/ >/dev/null 2>&1; then
    echo -e "  ${YELLOW}⚠️  Kong Gateway still accessible (may be another instance)${NC}"
else
    echo -e "  ${GREEN}✅ Kong Gateway not accessible${NC}"
fi

# ==============================================================================
# 7. CLEANUP COMPLETE
# ==============================================================================

print_header "✅ CLEANUP COMPLETE!"

echo -e "${GREEN}The following has been cleaned:${NC}"
echo -e "  ✅ Kong Konnect configuration (routes, services, plugins, consumers)"
echo -e "  ✅ Kong Data Plane Docker container (kong-demo-dp)"
echo -e "  ✅ Kubernetes resources (demo-api, ai-router, namespace)"
echo -e "  ✅ Port-forward processes"
echo -e "  ✅ Generated plugin configuration files"
echo -e ""
echo -e "${YELLOW}The following was preserved:${NC}"
echo -e "  📚 Documentation files (README.md, plugin_evolution.md)"
echo -e "  📜 Scripts (all setup scripts remain)"
echo -e "  🐳 Docker images (demo-api:latest, ai-router:latest)"
echo -e ""
echo -e "${BLUE}To start fresh, run:${NC}"
echo -e "  ${CYAN}cd scripts${NC}"
echo -e "  ${CYAN}./01-install-services.sh${NC}"
echo -e ""
echo -e "${BLUE}Then deploy Kong Data Plane:${NC}"
echo -e "  ${CYAN}# Follow Kong Konnect UI instructions to deploy Data Plane${NC}"
echo -e "  ${CYAN}# Or use: docker run -d --name kong-demo-dp ...${NC}"
echo -e ""
echo -e "${MAGENTA}Optional: Remove Docker images${NC}"
echo -e "  ${CYAN}docker rmi demo-api:latest ai-router:latest kong/kong-gateway:3.12${NC}"
echo -e ""

# Create a marker file
echo "Cleaned on $(date)" > .cleanup-marker

echo -e "${GREEN}🎉 Ready for a fresh start! 🎉${NC}\n"
