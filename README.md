# KloudOpsMonitor

Lightweight backend + agent system for monitoring infrastructure components.

## Architecture
- Backend: FastAPI + PostgreSQL
- Agent: Go
- Infra: Docker, Docker Compose
- CI/CD: GitHub Actions

## Project structure
agent/              # Go agent
backend-api/        # FastAPI backend
docker/             # docker-compose files
helm/               # future Kubernetes charts

## Requirements
- Docker + Docker Compose
- Go 1.22+
- Python 3.12+

## Local development

For local development, install dev dependencies via:
```bash
make venv && make install-deps
```
### Start dev stack (recommended)

Dev mode uses bind mounts + hot reload.
```bash
make dev-up
make dev-logs
```

### Stop dev stack
```bash
make dev-down
```

### Local “prod-like” stack

Runs without bind mounts / reload (closer to staging/prod).
```bash
make build
make up
make logs
```

### Run backend locally (without Docker)
```bash
make venv
make install-backend
make run-backend
```

### Run agent locally (without Docker)
```bash
make run-agent
```

## Lint

Runs Go vet + Python ruff (lint/format).
```bash
make lint
```

## Environments / Compose files

- docker/docker-compose.dev.yml — local dev (bind mounts, reload)
- docker/docker-compose.yml — local prod-like
- docker-compose.staging.yml — staging deploy (images from registry)
- docker-compose.prod.yml — production deploy (versioned images)

## CI/CD

- ci.yml — lint + docker build/push for branches
- release.yml — triggered by git tag vX.Y.Z (prod images + staging)
- production.yml — manual deploy to production (by version)