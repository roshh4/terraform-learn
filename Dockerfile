# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o backend

FROM gcr.io/distroless/base-debian12
WORKDIR /
COPY --from=builder /app/backend /backend
EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/backend"]


