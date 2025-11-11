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

show_menu() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}SELECT CLEANUP OPTIONS${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "${YELLOW}What would you like to clean?${NC}\n"
    echo -e "  ${GREEN}1)${NC} Kong Konnect Configuration (routes, services, plugins, consumers)"
    echo -e "  ${GREEN}2)${NC} Dev Portal (APIs, publications, pages)"
    echo -e "  ${GREEN}3)${NC} Kong Data Plane (Docker container)"
    echo -e "  ${GREEN}4)${NC} Kubernetes Resources (demo-api, ai-router, namespace)"
    echo -e "  ${GREEN}5)${NC} Port-Forward Processes"
    echo -e "  ${GREEN}6)${NC} Generated Plugin Files"
    echo -e "  ${GREEN}7)${NC} Temporary Portal Files"
    echo -e "  ${RED}8)${NC} ${RED}FULL CLEANUP (All of the above)${NC}"
    echo -e "  ${BLUE}0)${NC} Exit"
    echo -e ""
}

cd "$(dirname "$0")/.." || exit 1

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo -e "${GREEN}✅ Environment loaded from .env${NC}\n"
else
    echo -e "${YELLOW}⚠️  .env file not found. Some cleanup operations may be skipped.${NC}\n"
fi

print_header "🧹 SELECTIVE CLEANUP - CHOOSE WHAT TO CLEAN"

# Initialize cleanup flags
CLEAN_KONG_CONFIG=false
CLEAN_DEV_PORTAL=false
CLEAN_KONG_DP=false
CLEAN_K8S=false
CLEAN_PORT_FORWARDS=false
CLEAN_PLUGIN_FILES=false
CLEAN_TEMP_FILES=false

# Show menu and get user input
while true; do
    show_menu
    echo -ne "${YELLOW}Enter your choice (or multiple choices separated by space, e.g., '1 2 4'): ${NC}"
    read -r CHOICES

    # Exit if user chose 0
    if [[ "$CHOICES" == "0" ]]; then
        echo -e "${GREEN}Cleanup cancelled.${NC}"
        exit 0
    fi

    # Handle full cleanup
    if [[ "$CHOICES" == *"8"* ]]; then
        echo -e "\n${RED}⚠️  WARNING: This will DELETE EVERYTHING! ⚠️${NC}"
        echo -e "${YELLOW}Are you sure you want to perform a FULL CLEANUP? (yes/no)${NC}"
        read -r CONFIRM

        if [ "$CONFIRM" != "yes" ]; then
            echo -e "${GREEN}Full cleanup cancelled. Please select again.${NC}"
            continue
        fi

        CLEAN_KONG_CONFIG=true
        CLEAN_DEV_PORTAL=true
        CLEAN_KONG_DP=true
        CLEAN_K8S=true
        CLEAN_PORT_FORWARDS=true
        CLEAN_PLUGIN_FILES=true
        CLEAN_TEMP_FILES=true
        break
    fi

    # Parse individual choices
    for choice in $CHOICES; do
        case $choice in
            1) CLEAN_KONG_CONFIG=true ;;
            2) CLEAN_DEV_PORTAL=true ;;
            3) CLEAN_KONG_DP=true ;;
            4) CLEAN_K8S=true ;;
            5) CLEAN_PORT_FORWARDS=true ;;
            6) CLEAN_PLUGIN_FILES=true ;;
            7) CLEAN_TEMP_FILES=true ;;
            *)
                echo -e "${RED}Invalid choice: $choice${NC}"
                continue 2
                ;;
        esac
    done

    # Confirm selections
    echo -e "\n${CYAN}You selected:${NC}"
    $CLEAN_KONG_CONFIG && echo -e "  ${GREEN}✓${NC} Kong Konnect Configuration"
    $CLEAN_DEV_PORTAL && echo -e "  ${GREEN}✓${NC} Dev Portal"
    $CLEAN_KONG_DP && echo -e "  ${GREEN}✓${NC} Kong Data Plane"
    $CLEAN_K8S && echo -e "  ${GREEN}✓${NC} Kubernetes Resources"
    $CLEAN_PORT_FORWARDS && echo -e "  ${GREEN}✓${NC} Port-Forward Processes"
    $CLEAN_PLUGIN_FILES && echo -e "  ${GREEN}✓${NC} Generated Plugin Files"
    $CLEAN_TEMP_FILES && echo -e "  ${GREEN}✓${NC} Temporary Portal Files"

    echo -e "\n${YELLOW}Proceed with cleanup? (yes/no)${NC}"
    read -r CONFIRM

    if [ "$CONFIRM" = "yes" ]; then
        break
    else
        echo -e "${YELLOW}Let's try again...${NC}"
    fi
done

echo -e "\n${MAGENTA}Starting cleanup process...${NC}\n"

# ==============================================================================
# 1. CLEAN KONG KONNECT (CONTROL PLANE)
# ==============================================================================

if [ "$CLEAN_KONG_CONFIG" = true ]; then
    print_header "1. CLEANING KONG KONNECT (CONTROL PLANE)"

    # Use token from .env if available
    KONG_TOKEN="${DECK_KONNECT_TOKEN:-}"

    if [ -n "$KONG_TOKEN" ]; then
        echo -e "${BLUE}Cleaning Kong configuration using token from .env...${NC}"

        # Create empty configuration
        cat > /tmp/kong-empty.yaml << 'EOF'
_format_version: "3.0"

services: []
consumers: []
plugins: []
EOF

        echo -e "${CYAN}Applying empty configuration to remove all resources...${NC}"
        deck gateway sync \
            --konnect-control-plane-name="${DECK_KONNECT_CONTROL_PLANE_NAME:-Kong-Demo}" \
            --konnect-addr="${KONNECT_CONTROL_PLANE_URL:-https://in.api.konghq.com}" \
            --konnect-token="$KONG_TOKEN" \
            /tmp/kong-empty.yaml || echo -e "${YELLOW}Warning: Could not clean Kong config (might not exist)${NC}"

        rm -f /tmp/kong-empty.yaml
        echo -e "${GREEN}✅ Kong Konnect cleaned${NC}"
    else
        echo -e "${YELLOW}⏭️  Skipping Kong Konnect cleanup (no token found in .env)${NC}"
    fi
else
    echo -e "${BLUE}⏭️  Skipping Kong Konnect cleanup (not selected)${NC}"
fi

# ==============================================================================
# 1B. CLEAN DEV PORTAL (APIS & PUBLICATIONS)
# ==============================================================================

if [ "$CLEAN_DEV_PORTAL" = true ]; then
    print_header "1B. CLEANING DEV PORTAL (APIS & PUBLICATIONS)"

    if [ -n "$KONG_TOKEN" ]; then
        echo -e "${BLUE}Cleaning Dev Portal APIs and publications...${NC}"

        API_ENDPOINT="${KONNECT_CONTROL_PLANE_URL:-https://in.api.konghq.com}/v3"

        # Get all APIs
        APIS=$(curl -s "${API_ENDPOINT}/apis" \
            -H "Authorization: Bearer ${KONG_TOKEN}" \
            | jq -r '.data[]? | .id' 2>/dev/null)

        if [ -n "$APIS" ]; then
            echo "$APIS" | while read -r api_id; do
                if [ -n "$api_id" ] && [ "$api_id" != "null" ]; then
                    echo -e "${CYAN}  Deleting API: ${api_id}${NC}"
                    curl -s -X DELETE "${API_ENDPOINT}/apis/${api_id}" \
                        -H "Authorization: Bearer ${KONG_TOKEN}" >/dev/null 2>&1 || true
                fi
            done
            echo -e "${GREEN}✅ Dev Portal APIs cleaned${NC}"
        else
            echo -e "${YELLOW}⏭️  No Portal APIs found${NC}"
        fi

        # Clean up temporary portal files
        echo -e "${BLUE}Removing temporary portal files...${NC}"
        rm -f /tmp/portal-api-id.txt
        rm -f /tmp/demo-api-openapi.yaml
        rm -f /tmp/portal-landing-page.md
        rm -f /tmp/portal-api-docs.md
        rm -f /tmp/portal-guides.md
        rm -f /tmp/deck-dump-*.json
        echo -e "${GREEN}✅ Temporary portal files removed${NC}"
    else
        echo -e "${YELLOW}⏭️  Skipping Dev Portal cleanup (no token found in .env)${NC}"
    fi
else
    echo -e "${BLUE}⏭️  Skipping Dev Portal cleanup (not selected)${NC}"
fi

# ==============================================================================
# 2. KILL PORT-FORWARD PROCESSES
# ==============================================================================

if [ "$CLEAN_PORT_FORWARDS" = true ]; then
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
else
    echo -e "${BLUE}⏭️  Skipping port-forward cleanup (not selected)${NC}"
fi

# ==============================================================================
# 3. DELETE KUBERNETES RESOURCES
# ==============================================================================

if [ "$CLEAN_K8S" = true ]; then
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
else
    echo -e "${BLUE}⏭️  Skipping Kubernetes cleanup (not selected)${NC}"
fi

# ==============================================================================
# 4. DELETE GENERATED PLUGIN FILES
# ==============================================================================

if [ "$CLEAN_PLUGIN_FILES" = true ]; then
    print_header "4. CLEANING GENERATED PLUGIN FILES"

    echo -e "${BLUE}Removing generated Kong configuration files...${NC}"

    if [ -d "plugins" ]; then
        rm -f plugins/01-kong-basic.yaml
        rm -f plugins/02-kong-with-auth.yaml
        rm -f plugins/03-kong-with-ai-proxy.yaml
        rm -f plugins/04-kong-complete.yaml
        rm -f plugins/05-kong-with-semantic-cache.yaml
        rm -f plugins/06-kong-with-ollama-fixed.yaml
        rm -f plugins/07-kong-with-redis-plugins.yaml
        rm -f plugins/08-kong-with-semantic-guard.yaml

        # Keep documentation files
        echo -e "${CYAN}Keeping documentation files (README.md)${NC}"

        echo -e "${GREEN}✅ Generated plugin files removed${NC}"
    else
        echo -e "${YELLOW}⏭️  plugins directory not found${NC}"
    fi
else
    echo -e "${BLUE}⏭️  Skipping plugin files cleanup (not selected)${NC}"
fi

# ==============================================================================
# 5. STOP AND REMOVE KONG DATA PLANE CONTAINER
# ==============================================================================

if [ "$CLEAN_KONG_DP" = true ]; then
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
else
    echo -e "${BLUE}⏭️  Skipping Kong Data Plane cleanup (not selected)${NC}"
fi

# ==============================================================================
# 6. VERIFY CLEANUP
# ==============================================================================

print_header "6. VERIFYING CLEANUP"

echo -e "${BLUE}Checking cleanup status...${NC}\n"

# Check Kong Konnect APIs
if [ -n "$KONG_TOKEN" ]; then
    echo -e "${CYAN}Dev Portal APIs Status:${NC}"
    API_ENDPOINT="${KONNECT_CONTROL_PLANE_URL:-https://in.api.konghq.com}/v3"
    API_COUNT=$(curl -s "${API_ENDPOINT}/apis" \
        -H "Authorization: Bearer ${KONG_TOKEN}" \
        | jq -r '.data | length' 2>/dev/null || echo "0")
    if [ "$API_COUNT" -eq 0 ]; then
        echo -e "  ${GREEN}✅ No Portal APIs remaining${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $API_COUNT Portal API(s) still exist${NC}"
    fi
    echo ""
fi

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

echo -e "\n${CYAN}Kong Gateway Accessibility:${NC}"
if curl -s http://localhost:8000/ >/dev/null 2>&1; then
    echo -e "  ${YELLOW}⚠️  Kong Gateway still accessible (may be another instance)${NC}"
else
    echo -e "  ${GREEN}✅ Kong Gateway not accessible${NC}"
fi

# Check temporary portal files
echo -e "\n${CYAN}Temporary Portal Files Status:${NC}"
TEMP_FILES=$(ls /tmp/portal-api-id.txt /tmp/demo-api-openapi.yaml /tmp/portal-landing-page.md /tmp/portal-api-docs.md /tmp/portal-guides.md /tmp/deck-dump-*.json 2>/dev/null | wc -l | tr -d ' ')
if [ "$TEMP_FILES" -eq 0 ]; then
    echo -e "  ${GREEN}✅ No temporary portal files${NC}"
else
    echo -e "  ${YELLOW}⚠️  $TEMP_FILES temporary file(s) remain${NC}"
fi

# ==============================================================================
# 7. CLEANUP COMPLETE
# ==============================================================================

print_header "✅ CLEANUP COMPLETE!"

echo -e "${GREEN}The following has been cleaned:${NC}"
$CLEAN_KONG_CONFIG && echo -e "  ✅ Kong Konnect configuration (routes, services, plugins, consumers)"
$CLEAN_DEV_PORTAL && echo -e "  ✅ Dev Portal APIs and publications"
$CLEAN_KONG_DP && echo -e "  ✅ Kong Data Plane Docker container (kong-demo-dp)"
$CLEAN_K8S && echo -e "  ✅ Kubernetes resources (demo-api, ai-router, namespace)"
$CLEAN_PORT_FORWARDS && echo -e "  ✅ Port-forward processes"
$CLEAN_PLUGIN_FILES && echo -e "  ✅ Generated plugin configuration files"
$CLEAN_TEMP_FILES && echo -e "  ✅ Temporary portal files"
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
