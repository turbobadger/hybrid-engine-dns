#!/usr/bin/env bash

# Hybrid DNS status and quick checks
# Gives you a fast read on what’s running and whether lookups work.

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

echo "📊 hybrid-engine-dns status"
$DC ps || true

echo
echo "🧪 Basic DNS tests (edit to your real domains when customized):"
if command -v dig >/dev/null 2>&1; then
  echo -n "   External (example.com): "
  if dig @127.0.0.1 example.com +short > /dev/null 2>&1; then echo "✅"; else echo "❌"; fi
  echo -n "   Local domain (example.lan SOA): "
  if dig @127.0.0.1 example.lan SOA +short > /dev/null 2>&1; then echo "✅"; else echo "❌"; fi
  echo -n "   Split DNS (home.example.com SOA): "
  if dig @127.0.0.1 home.example.com SOA +short > /dev/null 2>&1; then echo "✅"; else echo "❌"; fi
else
  echo "   (dig not installed)"
fi

echo
echo "📝 Recent logs (last 5m):"
$DC logs --since 5m | tail -n 100 || true

