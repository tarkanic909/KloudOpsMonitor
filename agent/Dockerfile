# =========================
# 0️⃣ Multi-stage build, static Go binary, non-root user
# =========================

# =========================
# 1️⃣ Build stage
# =========================
FROM golang:1.22-alpine AS builder

# Build tools
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy go.mod/go.sum
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build binaries
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o agent ./cmd/agent


# =========================
# 2️⃣ Production image
# =========================
FROM gcr.io/distroless/base-debian12

WORKDIR /app

# Copy binaries from builder
COPY --from=builder /app/agent /app/agent

# Non-root user (Security)
USER nonroot:nonroot

# Port
EXPOSE 8080

ENTRYPOINT ["/app/agent"]

# =========================
# 3️⃣ Debug image
# =========================
FROM alpine:3.19 AS debug

WORKDIR /app
RUN apk add --no-cache ca-certificates curl bash
COPY --from=builder /app/agent /app/agent

EXPOSE 8080
ENTRYPOINT ["/app/agent"]