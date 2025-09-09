#!/usr/bin/env bash

# Start the hybrid DNS stack (Pi-hole + Unbound + BIND9 + Traefik)
# Casual but serious: this brings the whole thing up and does a few quick checks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Compose CLI detection (docker compose v2 preferred)
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DC="docker-compose"
else
  echo "❌ Error: Docker Compose not found. Install Docker Desktop or docker-compose."
  exit 1
fi

echo "🚀 Firing up hybrid-engine-dns (Pi-hole + Unbound + BIND9 + Traefik)..."

echo "📁 Project Directory: $PROJECT_DIR"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
  echo "❌ Error: Docker is not running. Please start Docker first."
  exit 1
fi

# Create directories
mkdir -p "$PROJECT_DIR/logs" "$PROJECT_DIR/unbound" "$PROJECT_DIR/traefik/acme" "$PROJECT_DIR/pihole/etc-pihole" "$PROJECT_DIR/pihole/etc-dnsmasq.d"

# Set safe perms for Traefik ACME storage
: > "$PROJECT_DIR/traefik/acme/acme.json" || true
chmod 600 "$PROJECT_DIR/traefik/acme/acme.json" || true

# Start containers
cd "$PROJECT_DIR"
$DC up -d

# Basic health wait
sleep 5

# Quick status
if $DC ps | grep -q "Up"; then
  echo "✅ Stack is up! Here's what's running:"
  $DC ps
else
  echo "❌ Failed to start. Recent logs:" && echo
  $DC logs --since 5m || true
  exit 1
fi

# Simple DNS smoke tests (uses example placeholders; swap to your domains when ready)
if command -v dig >/dev/null 2>&1; then
  echo
  echo "🧪 Quick DNS tests (edit to your real domains when you customize):"
  dig @127.0.0.1 example.com +short || echo "   External DNS test failed"
  dig @127.0.0.1 example.lan SOA +short || echo "   Local domain test (example.lan) will fail until you customize zones"
  dig @127.0.0.1 home.example.com SOA +short || echo "   Split-DNS test (home.example.com) will fail until you customize zones"
fi

echo
echo "📋 Heads up:"
echo "- Replace placeholder networks/domains in config/ and unbound/ to match your setup."
echo "- Update Traefik hostnames under home.example.com to your real subdomain."
echo "- Generate a real RNDC key: docker compose exec bind9 rndc-confgen -a"
echo "- Then restart: $SCRIPT_DIR/restart-dns.sh"

