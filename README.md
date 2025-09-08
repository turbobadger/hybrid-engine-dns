# turboDNS

Private WIP: a clean, reproducible, and privacy‑focused home lab DNS stack using Docker and BIND9/Unbound.

Goals
- Professional structure and automation from day one
- Strong defaults for privacy and security
- Reproducible Docker-based deployment for home networks

Images used
- ubuntu/bind9:9.18-22.04
- bind9:9.18-22.04

Status
- This repository starts private while building. Once stabilized and documented, it will be made public.

Quick start (placeholder)
- Coming soon. This will include Docker Compose and configuration examples for BIND9 and Unbound.

Development
- CI runs:
  - shellcheck (shell script static analysis)
  - shfmt (shell formatting checks)
  - hadolint (Dockerfile linter)
  - Trivy (repo/filesystem scan)
- Dependencies and GitHub Actions are kept current via Dependabot.

Contributing
- Please open an issue or start a Discussion to propose changes.
- PRs should be small, focused, and include rationale.

Security
- See SECURITY.md for reporting guidance. Avoid filing public issues for vulnerabilities.

License
- Apache-2.0. See LICENSE for details.

