.PHONY: help up down build lint run-agent

help:
	@echo "Available targets:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

up:
	docker compose -f docker/docker-compose.yml up -d

down:
	docker compose -f docker/docker-compose.yml down

build:
	docker compose -f docker/docker-compose.yml build

lint:
	cd agent && go vet ./...

## run-agent: - Run Go agent locally
run-agent:
	cd agent && go run ./cmd/agent
