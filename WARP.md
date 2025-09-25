# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

hybrid-engine-dns is a containerized DNS stack that combines:
- **Pi-hole** (DNS filtering + web UI, port 53)
- **Unbound** (recursive resolver with DNSSEC + DoT)
- **BIND9** (authoritative server for local zones)
- **Traefik** (reverse proxy with ACME DNS-01 for internal services)

The stack uses Docker Compose with a custom network (172.20.0.0/24) and sanitized example configurations that require customization with real domains and network ranges.

## Development Commands

### Core Operations
```bash
# Start the entire DNS stack
./scripts/start-dns.sh

# Stop the DNS stack
./scripts/stop-dns.sh

# Check status and run basic DNS tests
./scripts/status-dns.sh

# Restart after configuration changes
./scripts/restart-dns.sh
```

### Container Management
```bash
# View running services
docker compose ps

# View logs (all services or specific service)
docker compose logs -f
docker compose logs -f pihole

# Validate compose configuration
docker compose config

# Rebuild and restart after config changes
docker compose down && docker compose up -d
```

### Configuration Validation
```bash
# Validate BIND9 configuration
docker compose exec bind9 named-checkconf /etc/bind/named.conf

# Validate zone files
docker compose exec bind9 named-checkzone example.lan /var/lib/bind/db.example.lan

# Check Unbound configuration
docker compose exec unbound unbound-checkconf /opt/unbound/etc/unbound/unbound.conf

# Test DNS resolution
dig @127.0.0.1 example.com +short
dig @127.0.0.1 example.lan SOA +short
```

## Architecture Overview

### Network Flow
1. **Client DNS Query → Pi-hole (172.20.0.9:53)**
   - Blocks ads/malware using configured blocklists
   - Forwards legitimate queries to Unbound

2. **Pi-hole → Unbound (172.20.0.10:53)**
   - Recursive resolution with DNSSEC validation
   - DNS-over-TLS to upstream providers (Cloudflare, Quad9, Google)
   - Forwards local domain queries to BIND9

3. **Unbound → BIND9 (172.20.0.11:53)**
   - Authoritative responses for:
     - `example.lan` (internal-only domain)
     - `home.example.com` (split-DNS subdomain)
     - Reverse DNS for RFC 1918 networks

4. **Traefik (172.20.0.8) → Internal Services**
   - HTTPS termination with Let's Encrypt wildcard certificates
   - Routes `*.home.example.com` to internal services

### Service Dependencies
```
Traefik → Pi-hole
         ↓
      Unbound ← Pi-hole
         ↓
      BIND9 ← Unbound
```

## Key Configuration Files

### Network and Domain Configuration
- `config/named.conf` - ACLs and network ranges (update `internal_networks`)
- `config/named.conf.local` - Zone definitions
- `unbound/unbound.conf` - Access control, stub zones, upstream forwarders
- `zones/db.example.lan` - Local domain A/AAAA records
- `zones/db.home.example.com` - Internal services subdomain

### Service Configuration
- `docker-compose.yml` - Main stack configuration
- `.env` - Environment variables (not committed, needs creation)
- `config/rndc.key` - BIND9 control key (auto-generated)

### Required Customization (TODOs in configs)
1. Replace `example.lan` and `home.example.com` with real domains
2. Update network ranges from examples (10.10.0.0/24, etc.) to actual VLANs
3. Set environment variables in `.env`:
   - `ACME_EMAIL` - Let's Encrypt email
   - `ACME_DNS_PROVIDER` - DNS provider (cloudflare, route53, etc.)
   - Provider-specific tokens (e.g., `CF_DNS_API_TOKEN`)
   - `PIHOLE_WEBPASSWORD` - Pi-hole admin password

### Configuration Reload Behavior
- **BIND9**: Automatic reload via `rndc reload` or container restart
- **Unbound**: Requires container restart for config changes
- **Pi-hole**: Live reload for most settings via web UI
- **Traefik**: Automatic reload for dynamic configuration files

## Development Patterns

### Adding New Internal Services
1. Add DNS record in `zones/db.home.example.com`:
   ```
   myapp    IN    A    192.168.50.100
   ```
2. Add Traefik labels to service in `docker-compose.yml`:
   ```yaml
   labels:
     - "traefik.enable=true"
     - "traefik.http.routers.myapp.rule=Host(`myapp.home.example.com`)"
     - "traefik.http.routers.myapp.entrypoints=websecure"
     - "traefik.http.routers.myapp.tls=true"
     - "traefik.http.routers.myapp.tls.certresolver=le"
   ```
3. Increment SOA serial in zone file
4. Reload: `./scripts/restart-dns.sh`

### Zone File Management
- Use YYYYMMDDNN format for SOA serial (e.g., 2025090801)
- Group records by network/VLAN for clarity
- Test changes with `named-checkzone` before applying

### Network Customization
1. Update ACLs in `config/named.conf`
2. Modify access control in `unbound/unbound.conf`
3. Add corresponding reverse zones in `config/named.conf.local`
4. Create reverse zone files in `zones/`

## Testing and Validation

### Basic Functionality Tests
```bash
# Test external DNS resolution
dig @127.0.0.1 google.com +short

# Test local domain (should work after customization)
dig @127.0.0.1 example.lan SOA +short

# Test split-DNS subdomain
dig @127.0.0.1 home.example.com SOA +short

# Test reverse DNS
dig @127.0.0.1 -x 192.168.50.1 +short

# Test DNSSEC validation
dig @127.0.0.1 cloudflare.com +dnssec +short
```

### Service Health Checks
```bash
# Container health status
docker compose ps

# Pi-hole admin interface (customize domain)
curl -k https://pihole.home.example.com/admin/

# Unbound control
docker compose exec unbound unbound-control status

# BIND9 status
docker compose exec bind9 rndc status
```

### CI Validation (runs on push/PR)
- **shellcheck** - Shell script static analysis
- **shfmt** - Shell formatting checks  
- **hadolint** - Dockerfile linting (if Dockerfiles exist)
- **Trivy** - Security scanning (non-blocking)

### Manual Linting
```bash
# Check shell scripts
shellcheck scripts/*.sh

# Format shell scripts
shfmt -w -i 2 -s scripts/*.sh

# Validate Docker Compose
docker compose config --quiet
```

## References

- **README.md** - Project overview and quick start
- **CONTRIBUTING.md** - PR guidelines and local checks
- **docs/MAINTENANCE.md** - Detailed customization and workflow guide
- **SECURITY.md** - Security reporting guidelines

## Notes for WARP Agents

- All example domains (`example.lan`, `home.example.com`) and network ranges are placeholders
- Look for `TODO:` comments in config files for required customizations
- The stack is designed for home lab environments with multiple VLANs
- Configuration changes typically require container restart via scripts
- Use the provided scripts rather than direct `docker compose` commands for reliability