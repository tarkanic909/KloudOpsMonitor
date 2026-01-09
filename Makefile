.PHONY: help up down build lint run-backend run-agent

help:
	@echo "Available targets:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## up: - Start local stack
up:
	docker compose --env-file .env -f docker/docker-compose.yml up -d

## down: - Stop local stack
down:
	docker compose --env-file .env -f docker/docker-compose.yml down

## build: - Build all Docker images
build:
	docker compose --env-file .env -f docker/docker-compose.yml build

## lint: - Run linters
lint:
	cd agent && go vet ./...
	
## venv: Create Python virtual environment
venv:
	cd backend-api && python3 -m venv .venv

## install-backend: Install backend dependencies into venv
install-backend:
	cd backend-api && . .venv/bin/activate && pip install -r requirements.txt

## run-backend: Run FastAPI locally (dev)
run-backend:
	cd backend-api && . .venv/bin/activate && \
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

## run-agent: - Run Go agent locally
run-agent:
	cd agent && go run ./cmd/agent

## dev-up: Start dev stack with live reload
dev-up:
	docker compose --env-file .env -f docker/docker-compose.dev.yml up -d --build