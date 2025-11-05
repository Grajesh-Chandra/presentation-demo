#!/bin/bash

# ==============================================================================
# Load Environment Variables
# ==============================================================================
# Loads environment variables from .env file
# ==============================================================================

set -euo pipefail

if [ -f .env ]; then
  set -a
  source .env
  set +a
  echo "✅ Environment variables loaded from .env"
else
  echo "❌ Error: .env file not found"
  echo "📝 Copy .env.example to .env and fill in your values:"
  echo "   cp .env.example .env"
  exit 1
fi
