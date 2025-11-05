#!/bin/bash

# ==============================================================================
# 01 - Install Services (Demo API & AI Router)
# ==============================================================================
# This script performs a COMPLETE cleanup and fresh installation
# ==============================================================================

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "\n${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║  $1${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Navigate to project root
cd "$(dirname "$0")/.." || exit 1

print_header "STEP 01: INSTALL SERVICES"

# Cleanup
print_info "Cleaning up old resources..."
pkill -f "kubectl port-forward" 2>/dev/null || true
kubectl delete namespace demo-apis --timeout=60s 2>/dev/null || true
docker rmi -f demo-api:latest ai-router:latest 2>/dev/null || true
sleep 3

# Build images
print_info "Building Demo API image..."
cd api-examples/nodejs-api
docker build -t demo-api:latest . -q
cd ../..

print_info "Building AI Router image..."
cd ai-services/ai-router
docker build -t ai-router:latest . -q
cd ../..

# Deploy to Kubernetes
print_info "Creating namespace..."
kubectl create namespace demo-apis

print_info "Deploying Demo API..."
kubectl apply -f api-examples/nodejs-api/deployment.yaml
kubectl wait --for=condition=available deployment/demo-api -n demo-apis --timeout=120s

print_info "Deploying AI Router..."
kubectl apply -f ai-services/ai-router/deployment.yaml
kubectl wait --for=condition=available deployment/ai-router -n demo-apis --timeout=120s

# Port forwarding
print_info "Setting up port forwards..."
kubectl port-forward -n demo-apis svc/demo-api 3000:3000 &>/dev/null &
sleep 2
kubectl port-forward -n demo-apis svc/ai-router-service 8080:8080 &>/dev/null &
sleep 2

print_success "Services installed successfully!"
echo ""
kubectl get all -n demo-apis

echo -e "\n${GREEN}Next Step: Run ${YELLOW}./02-test-without-kong.sh${NC}"
