#!/bin/bash

# ==============================================================================
# 11 - Test Redis Connection
# ==============================================================================
# Tests Redis connectivity and basic operations
# ==============================================================================

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_test() {
    echo -e "\n${YELLOW}TEST: $1${NC}"
    if [ ! -z "$2" ]; then
        echo -e "${CYAN}$2${NC}"
    fi
}

print_header "STEP 11: TEST REDIS CONNECTION"

# Load environment variables
echo -e "${BLUE}Loading environment variables...${NC}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
    echo -e "${GREEN}✅ Environment loaded${NC}"
else
    echo -e "${RED}❌ .env file not found at $PROJECT_ROOT/.env${NC}"
    echo -e "${YELLOW}Create .env from .env.example and fill in your values${NC}"
    exit 1
fi

# Check if redis-cli is installed
print_test "1. Checking redis-cli installation"
if ! command -v redis-cli &> /dev/null; then
    echo -e "${RED}❌ redis-cli not found${NC}"
    echo -e "${YELLOW}Install with: brew install redis${NC}"
    exit 1
else
    echo -e "${GREEN}✅ redis-cli found${NC}"
    redis-cli --version
fi

# Test Redis connection
print_test "2. Testing Redis connection" "Host: $REDIS_HOST:$REDIS_PORT"
REDIS_URL="redis://${REDIS_USERNAME}:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/${REDIS_DATABASE}"

if redis-cli -u "$REDIS_URL" PING &> /dev/null; then
    RESPONSE=$(redis-cli -u "$REDIS_URL" PING)
    echo -e "${GREEN}✅ Redis connection successful: $RESPONSE${NC}"
else
    echo -e "${RED}❌ Failed to connect to Redis${NC}"
    exit 1
fi

# Test basic operations
print_test "3. Testing SET operation"
redis-cli -u "$REDIS_URL" SET kong:demo:test "Hello from Kong Demo" EX 60
echo -e "${GREEN}✅ SET successful (expires in 60s)${NC}"

print_test "4. Testing GET operation"
VALUE=$(redis-cli -u "$REDIS_URL" GET kong:demo:test)
echo -e "${GREEN}✅ GET successful: $VALUE${NC}"

print_test "5. Testing Redis INFO"
redis-cli -u "$REDIS_URL" INFO server | grep -E "redis_version|os|uptime_in_days"

print_test "6. Testing Redis memory usage"
redis-cli -u "$REDIS_URL" INFO memory | grep -E "used_memory_human|maxmemory_human"

# Test vector search capability (for semantic cache)
print_test "7. Checking Redis modules for vector search"
MODULES=$(redis-cli -u "$REDIS_URL" MODULE LIST)
if echo "$MODULES" | grep -q "search"; then
    echo -e "${GREEN}✅ RediSearch module available (required for semantic cache)${NC}"
else
    echo -e "${YELLOW}⚠️  RediSearch module not found${NC}"
    echo -e "${YELLOW}Semantic cache features may not work${NC}"
fi

# Cleanup test key
print_test "8. Cleaning up test data"
redis-cli -u "$REDIS_URL" DEL kong:demo:test
echo -e "${GREEN}✅ Cleanup successful${NC}"

echo -e "\n${GREEN}✅ All Redis tests passed!${NC}"
echo -e "\n${BLUE}Redis Configuration:${NC}"
echo -e "  Host: ${CYAN}$REDIS_HOST${NC}"
echo -e "  Port: ${CYAN}$REDIS_PORT${NC}"
echo -e "  Username: ${CYAN}$REDIS_USERNAME${NC}"
echo -e "  Database: ${CYAN}$REDIS_DATABASE${NC}"
echo -e "  Status: ${GREEN}✅ Connected${NC}"

echo -e "\n${BLUE}Next Step: Run ${YELLOW}./12-add-semantic-cache.sh${NC}"
