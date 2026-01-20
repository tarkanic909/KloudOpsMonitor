.PHONY: help up down build lint lint-go lint-python run-backend run-agent dev dev-up dev-down dev-logs

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

## logs: - Tail local prod-like logs
logs:
	docker compose --env-file .env -f docker/docker-compose.yml logs -f

## lint: - Run all linters
lint: lint-go lint-python

## lint-go: - Run Go linters
lint-go:
	cd agent && go vet ./...
	
## venv: Create Python virtual environment
venv:
	cd backend-api && python3 -m venv .venv

## install-backend: - Install backend runtime deps
install-backend: venv
	cd backend-api && . .venv/bin/activate && \
	pip install -r requirements.txt

## install-backend-dev: - Install backend dev deps
install-backend-dev: venv
	cd backend-api && . .venv/bin/activate && \
	pip install -r requirements-dev.txt

## install-deps: - Install all backend deps (runtime + dev)
install-deps: install-backend install-backend-dev

## lint-python: - Lint & format Python code
lint-python:
	cd backend-api && . .venv/bin/activate && \
	ruff check app && \
	ruff format app
	
## format-python: - Format Python code
format-python:
	cd backend-api && . .venv/bin/activate && \
	black app

## run-backend: - Run FastAPI locally (dev)
run-backend:
	cd backend-api && . .venv/bin/activate && \
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

## run-agent: - Run Go agent locally
run-agent:
	cd agent && go run ./cmd/agent
	
## dev: - Start dev stack
dev: dev-up

## dev-up: - Start dev stack with live reload
ifndef CI
dev-up:
	docker compose --env-file .env -f docker/docker-compose.dev.yml up -d --build
endif

## dev-down: - Stop dev stack
dev-down:
	docker compose --env-file .env -f docker/docker-compose.dev.yml down

## dev-logs: - Tail logs
dev-logs:
	docker compose --env-file .env -f docker/docker-compose.dev.yml logs -f

## precommit-install: - Install pre-commit hooks
precommit-install:
	backend-api/.venv/bin/pre-commit install

## precomit-run: - Run pre-commit hooks
precommit-run:
	backend-api/.venv/bin/pre-commit run --all-files
