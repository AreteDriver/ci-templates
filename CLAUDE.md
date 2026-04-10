# CI Templates — CLAUDE.md

## Project Overview

**Type**: DevOps template library
**Language**: YAML (GitHub Actions), Dockerfile, HCL (Terraform), Bash
**Purpose**: Reusable CI/CD and infrastructure templates extracted from 20+ production repos
**Owner**: AreteDriver
**License**: MIT

---

## Architecture

```
ci-templates/
├── python/                 # Python CI + release (ruff, pytest, PyPI OIDC publish)
├── rust/                   # Rust CI + release (cargo fmt/clippy/test, benchmarks)
├── node/                   # Node.js CI (ESLint, Vitest, Playwright E2E)
├── docker/                 # Dockerfile templates (multi-stage, distroless)
├── kubernetes/             # K8s manifests, Helm charts
├── monitoring/             # Prometheus, Grafana, alerting
├── shared/                 # Cross-language shared workflows
├── LICENSE
└── README.md
```

---

## File Conventions

- One directory per language/technology
- Template files use actual GitHub Actions YAML syntax (copy-paste ready)
- Comments explain customization points

---

## Common Commands

```bash
# Validate YAML syntax
yamllint .

# Test workflows locally (act)
act -W python/ci.yml
```

---

## Git Conventions

- Conventional commits: `feat:`, `fix:`, `docs:`
- Branch: main
