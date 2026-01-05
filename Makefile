.PHONY: help up down build lint run-agent

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

## run-agent: - Run Go agent locally
run-agent:
	cd agent && go run ./cmd/agent
