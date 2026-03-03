# CI/CD & Infrastructure Templates

Reusable DevOps templates extracted from production systems across 20+ repositories. Not theoretical — every template here is running in CI or deployed infrastructure.

## What's Here

```
python/          Python CI + release workflows (ruff, pytest, PyPI OIDC publish)
rust/            Rust CI + release workflows (cargo fmt/clippy/test, benchmark tracking)
node/            Node.js CI workflows (ESLint, Vitest, Playwright E2E)
shared/          Cross-language: CodeQL, gitleaks, Dependabot configs
docker/          Multi-stage Dockerfiles + production docker-compose
kubernetes/      K8s manifests (Deployment, HPA, Ingress, Kustomize)
monitoring/      Prometheus alerting rules (14 rules, 7 groups)
```

## Pipeline Capabilities

These templates cover the full CI/CD lifecycle:

| Stage | Templates | What It Does |
|-------|-----------|-------------|
| **Lint** | `python/ci.yml`, `rust/ci.yml`, `node/ci.yml` | ruff, cargo fmt/clippy, ESLint |
| **Test** | `python/ci.yml`, `rust/ci.yml`, `node/ci.yml` | pytest matrix, cargo test, Vitest + Playwright E2E |
| **Security** | `shared/codeql.yml`, `shared/secret-scan.yml` | SAST, secret scanning, dependency audit |
| **Build** | `docker/python-multistage.Dockerfile` | Multi-stage builds, non-root users, health checks |
| **Release** | `python/release.yml`, `rust/release.yml` | PyPI OIDC Trusted Publisher, GitHub Releases |
| **Deploy** | `docker/docker-compose.yml`, `kubernetes/` | Docker Compose (5 services), K8s with HPA |
| **Monitor** | `monitoring/alerts.yml` | Prometheus alerting (cache, latency, errors, DDoS) |

## Where These Run

| Repo | Workflows | Live Deploy | Coverage Gate |
|------|-----------|-------------|---------------|
| [BenchGoblins](https://github.com/Arete-Consortium/BenchGoblins) | 6 workflows | Fly.io + Vercel | 99% |
| EVE_Gatekeeper | 5 workflows + K8s + Helm | GHCR | 80% |
| [animus](https://github.com/AreteDriver/animus) | 4 workflows | — | 97% |
| [RedOPS](https://github.com/AreteDriver/RedOPS) | 5 workflows | GHCR (multi-arch) | — |
| [convergent](https://github.com/AreteDriver/convergent) | 5 workflows | PyPI | — |
| [Argus Overview](https://github.com/AreteDriver/Argus_Overview) | 9 workflows | PyPI + AppImage + .exe | 80% |

**83 workflow files across 20 repos. 0 open code scanning alerts.**

## Docker

### `docker/python-multistage.Dockerfile`
Two-stage Python build. Builder installs deps into a venv, runtime copies only the venv. Non-root user, health check, ~150MB final image.

### `docker/nextjs-multistage.Dockerfile`
Three-stage Next.js build (deps → build → standalone runtime). Non-root user, ~120MB final image.

### `docker/docker-compose.yml`
Production-ready compose with API + PostgreSQL + Redis. Health checks on all services, named volumes, optional backup profile with pg_dump + 7-day retention.

## Kubernetes

Production K8s manifests extracted from EVE_Gatekeeper:

- **`deployment.yaml`** — 2 replicas, rolling update (zero-downtime), security-hardened (readOnlyRootFilesystem, drop ALL capabilities, non-root), Prometheus scrape annotations, pod anti-affinity
- **`hpa.yaml`** — Autoscale 2-10 replicas on CPU (70%) / memory (80%), scale-down stabilization
- **`ingress.yaml`** — nginx with rate limiting, WebSocket support, TLS
- **`service.yaml`** — ClusterIP for API, PostgreSQL, Redis
- **`kustomization.yaml`** — Apply the full stack with `kubectl apply -k kubernetes/`

## Monitoring

### `monitoring/alerts.yml`
14 Prometheus alert rules across 7 groups:
- **Cache** — Miss rate warnings at 50% and 80%
- **Latency** — P95 thresholds at 2s (warning) and 5s (critical)
- **Errors** — 5xx rate gates at 5% and 10%, client error spike detection
- **Degradation** — Component health status monitoring
- **External APIs** — Error rate and availability for upstream services
- **WebSocket** — Connection drop detection
- **Availability** — No-traffic detection, DDoS detection (>1000 req/s)

## Security Scanning Stack

These repos use a layered security approach:

| Tool | Purpose | Repos |
|------|---------|-------|
| **gitleaks** | Secret scanning (pre-commit + CI) | 14/20 |
| **CodeQL** | SAST (security + quality queries) | 14/20 |
| **pip-audit** | Python dependency vulnerabilities | 12/20 |
| **Bandit** | Python security linter | 3 |
| **Semgrep** | Multi-language SAST rules | 1 |
| **Trivy** | Container + IaC scanning | 2 |
| **TruffleHog** | Verified secret detection | 1 |
| **Dependabot** | Automated dependency updates | All |

## Usage

Copy the templates you need into your `.github/workflows/` directory and adjust:
- Python versions in matrix
- Coverage thresholds
- Docker image names
- K8s namespace and resource limits
- Prometheus label selectors
