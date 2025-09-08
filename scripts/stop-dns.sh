#!/usr/bin/env bash

# Stop the hybrid DNS stack
# Short and sweet.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  echo "❌ Error: Docker Compose not found."
  exit 1
fi

cd "$PROJECT_DIR"

echo "🛑 Stopping hybrid-engine-dns..."
$DC down || $DC stop

echo "✅ Done."

