#!/bin/bash

set -euo pipefail

# Set platform (default to amd64, can be overridden with PLATFORM env var)
PLATFORM=${PLATFORM:-linux/amd64}

# Set buf registry flags (configurable via env vars)
VISIBILITY=${VISIBILITY:-public}
OVERRIDE_REMOTE=${OVERRIDE_REMOTE:-bufbuild.internal}

# Build and upload multi plugin (go base plugin)
echo "Building multi plugin..."
docker buildx build \
    -f go-plugins/multi/Dockerfile \
    --platform "${PLATFORM}" \
    -t bufbuild.internal/go-plugins/go:v1.36.6 \
    ./go-plugins/multi

echo "Uploading multi plugin..."
buf beta registry plugin push \
    --visibility "${VISIBILITY}" \
    --override-remote "${OVERRIDE_REMOTE}" \
    --image bufbuild.internal/go-plugins/go:v1.36.6 \
    ./go-plugins/multi

# Build and upload grpc plugin
echo "Building grpc plugin..."
docker buildx build \
    --platform "${PLATFORM}" \
    -f go-plugins/grpc/Dockerfile \
    -t bufbuild.internal/go-plugins/grpc:v1.5.1 \
    ./go-plugins/grpc

echo "Uploading grpc plugin..."
buf beta registry plugin push \
    --visibility "${VISIBILITY}" \
    --override-remote "${OVERRIDE_REMOTE}" \
    --image bufbuild.internal/go-plugins/grpc:v1.5.1 \
    ./go-plugins/grpc

# Build and upload gateway plugin
echo "Building gateway plugin..."
docker buildx build \
    --platform "${PLATFORM}" \
    -f go-plugins/gateway/Dockerfile \
    -t bufbuild.internal/go-plugins/gateway:v2.27.0 \
    ./go-plugins/gateway

echo "Uploading gateway plugin..."
buf beta registry plugin push \
    --visibility "${VISIBILITY}" \
    --override-remote "${OVERRIDE_REMOTE}" \
    --image bufbuild.internal/go-plugins/gateway:v2.27.0 \
    ./go-plugins/gateway

echo "All plugins built and uploaded successfully!"
