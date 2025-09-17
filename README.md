# hybrid-engine-dns

A friendly, no‑nonsense DNS stack for your home lab. It blends BIND9 (authoritative), Unbound (recursive + DNSSEC), Pi-hole (filtering + UI), and Traefik (reverse proxy) so you get fast lookups, solid privacy, smart caching, clean ad/malware blocking, and sweet HTTPS on your internal subdomain.

Why this exists
- I like speed, privacy, and control — without duct tape
- I want local names that make sense (hello, apps at home.example.com and example.lan)
- I want Pi-hole’s blocklists plus proper recursive + authoritative DNS, all Dockerized

What you get
- BIND9 for local zones and a private subdomain
- Unbound for fast, privacy‑oriented recursive resolution (with DNS‑over‑TLS)
- Pi-hole for ad/tracker blocking (bring your own lists)
- Traefik reverse proxy with ACME DNS‑01 (wildcards) for your internal subdomain
- Dockerized, reproducible setup tailored for home networks

Status
- WIP while I shape this up. Private for now; going public once the docs and defaults are tight.

Placeholders and safety
- This repo ships with sanitized example domains and IPs:
  - Internal domain: example.lan
  - Split‑DNS subdomain: home.example.com
  - Example IPs: RFC 5737 test ranges (like 192.0.2.x)
- Everywhere you see a TODO comment, swap in your real info. I’ll point it out inline.

Quick start
- Compose + configs are included with safe placeholders.
- Start with the scripts in scripts/ or run docker compose up -d once you’ve filled the TODOs.

Development
- CI runs:
  - shellcheck (shell script static analysis)
  - shfmt (shell formatting checks)
  - hadolint (Dockerfile linter, if Dockerfiles exist)
  - Trivy (repo/filesystem scan, non‑blocking)
- Dependabot keeps Actions and Docker bits fresh.

Contributing
- Ideas and feedback welcome — start a Discussion or a focused PR.
- Keep changes small and purposeful; explain the “why.”

Security
- See SECURITY.md for reporting guidance. Avoid filing public issues for vulnerabilities.

License
- Apache‑2.0. See LICENSE for details.

# Trigger CI test
