#!/usr/bin/env bash

# Restart the hybrid DNS stack
# Quick bounce to apply changes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/stop-dns.sh"

echo "⏳ Waiting 2s..."
sleep 2

"$SCRIPT_DIR/start-dns.sh"

