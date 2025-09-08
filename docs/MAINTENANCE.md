# How to modify this repo (step by step)

Friendly guide so Future You (and PR reviewers) stay happy.

0) Ground rules (quick vibe check)
- Never commit secrets. Use .env, config/rndc.key (ignored), and provider tokens via env.
- Keep changes small and focused. One idea per PR.
- Write docs and comments in a casual, confident tone. Helpful > formal.

1) Branching
- Base off main: git fetch origin && git switch -c <type>/<short-topic> origin/main
- Name it like: feat/add-pihole-upstreams or fix/zone-typo or docs/readme-polish

2) Make your changes
- DNS zones: edit files under zones/ and bump the SOA serial (YYYYMMDDNN)
- BIND config: config/named.conf* (authoritative only)
- Unbound: unbound/unbound.conf (stub-zones, access-control, upstreams)
- Traefik: traefik/dynamic/*.yml (hostnames, backends)
- Compose: docker-compose*.yml (services, networks)
- Scripts: scripts/*.sh (keep them POSIX-friendly and chill)

3) Local checks (fast)
- Shell: shellcheck scripts/*.sh (or let CI do it, but local is faster)
- Format: shfmt -w scripts (CI runs -d to diff)
- Dockerfiles (if any): hadolint <Dockerfile>
- Optional: run docker compose config to validate compose syntax

4) Run it (if applicable)
- Start: ./scripts/start-dns.sh
- Status: ./scripts/status-dns.sh
- Logs: docker compose logs -f (or target a service)
- Stop: ./scripts/stop-dns.sh

5) Commit
- Conventional-ish is great: "feat:", "fix:", "docs:", "chore:" etc.
- Example: git add -A && git commit -m "feat: add split-DNS example zone"

6) Push and open PR
- git push -u origin <branch>
- gh pr create --base main --head <branch> --title "feat: ..." --body "..."

7) CI and reviews
- Wait for the "ci" check to pass (lint/scan). Fix anything it flags.
- Keep the convo friendly. If you change behavior, add a line to README or leave a crisp note.

8) Merge
- Squash merge is the default vibe (clean history). Auto-delete branches after merge is enabled.

9) Post-merge
- If you changed zones or configs, restart the stack:
  - ./scripts/restart-dns.sh

10) Versioning/Releases (optional)
- If/when we start tagging releases, use SemVer: v0.1.0, v0.2.0, ...
- Use GitHub Releases to write human-friendly release notes.

Secrets playbook
- .env (not committed): ACME_EMAIL, ACME_DNS_PROVIDER, provider tokens like CF_DNS_API_TOKEN
- config/rndc.key: ignored; generate with: docker compose exec bind9 rndc-confgen -a
- Never print secrets in logs or echo them in scripts

Customization checklist
- Domains: example.lan → your internal domain; home.example.com → your subdomain
- Networks: replace 10.10/10.20/10.30/10.40 and 192.168.50 with your VLAN CIDRs
- Traefik routes: point hostnames and backend URLs at your real services
- Pi-hole: set WEBPASSWORD via env (and consider auth middleware in Traefik)

Tone/style (docs + code comments)
- Keep it casual, friendly, and confident (like you’ve done this before)
- Be specific and helpful; prefer examples over theory
- Use TODO notes where users must swap in their own values
- Avoid shouting; emojis optional but welcomed where it helps

