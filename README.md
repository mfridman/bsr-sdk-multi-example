# bsr-sdk-multi-example

This repository demonstrates building and uploading custom Buf plugins to the Buf Schema Registry (BSR):

1. **Multi-plugin** - Go base plugin bundled with vtprotobuf and go-json plugins
2. **gRPC plugin** - gRPC service generation with dependency on the base plugin
3. **Gateway plugin** (optional) - gRPC-Gateway HTTP proxy generation

The plugins form a dependency chain resulting in separate Go modules when used with Generated SDKs.

<p align="center">
  <img src="./image.png" width="50%">
</p>

Multi-plugins bundle multiple generators that output to the same package using:

https://github.com/bufbuild/tools/tree/7b00c24c/cmd/protoc-gen-multi

## Plugin Overview

The plugins are organized in `./go-plugins/`:

- **Multi Plugin** (`go-plugins/multi/`) - Base Go plugin with vtprotobuf and go-json plugins
- **gRPC Plugin** (`go-plugins/grpc/`) - gRPC service generation
- **Gateway Plugin** (`go-plugins/gateway/`) - gRPC-Gateway HTTP proxy generation

## Step 1 - Multi-plugin (Base Go Plugin)

Build and upload the multi-plugin that bundles multiple generators:

- [`protoc-gen-go`](https://pkg.go.dev/google.golang.org/protobuf@v1.36.6/cmd/protoc-gen-go)
- [`protoc-gen-go-vtproto`](https://pkg.go.dev/github.com/planetscale/vtprotobuf/cmd/protoc-gen-go-vtproto)
- [`protoc-gen-go-json`](https://pkg.go.dev/github.com/mfridman/protoc-gen-go-json)

See [go-plugins/multi/Dockerfile](./go-plugins/multi/Dockerfile) and [go-plugins/multi/buf.plugin.yaml](./go-plugins/multi/buf.plugin.yaml).

```shell
# Build the multi-plugin image
docker buildx build \
    -f go-plugins/multi/Dockerfile \
    --platform linux/amd64 \
    -t bufbuild.internal/go-plugins/go:v1.36.6 \
    ./go-plugins/multi

# Upload to BSR
buf beta registry plugin push \
    --visibility public \
    --override-remote bufbuild.internal \
    --image bufbuild.internal/go-plugins/go:v1.36.6 \
    ./go-plugins/multi
```

**Note:** The version is set to `v1.36.6` to match `protoc-gen-go`. Use `go-plugins` as the
organization (avoid reserved names like `protocolbuffers`) and `go` as the plugin name.

## Step 2 - gRPC Plugin

Build and upload the gRPC plugin that depends on the base multi-plugin. It uses a patched `protoc-gen-go-grpc` to output to a **separate package**, enabling dependency relationships between plugins.

- [`protoc-gen-go-grpc`](https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1)

See [go-plugins/grpc/Dockerfile](./go-plugins/grpc/Dockerfile) and [go-plugins/grpc/buf.plugin.yaml](./go-plugins/grpc/buf.plugin.yaml).

```shell
# Build the gRPC plugin image
docker buildx build \
    --platform linux/amd64 \
    -f go-plugins/grpc/Dockerfile \
    -t bufbuild.internal/go-plugins/grpc:v1.5.1 \
    ./go-plugins/grpc

# Upload to BSR
buf beta registry plugin push \
    --visibility public \
    --override-remote bufbuild.internal \
    --image bufbuild.internal/go-plugins/grpc:v1.5.1 \
    ./go-plugins/grpc
```

## Step 3 - gRPC Gateway Plugin (Optional)

Build and upload the gRPC Gateway plugin that generates HTTP/JSON proxy code. It depends on both the base multi-plugin and the gRPC plugin.

- [`protoc-gen-grpc-gateway`](https://pkg.go.dev/github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.27.0)

See [go-plugins/gateway/Dockerfile](./go-plugins/gateway/Dockerfile) and [go-plugins/gateway/buf.plugin.yaml](./go-plugins/gateway/buf.plugin.yaml).

```shell
# Build the gateway plugin image
docker buildx build \
    --platform linux/amd64 \
    -f go-plugins/gateway/Dockerfile \
    -t bufbuild.internal/go-plugins/gateway:v2.27.0 \
    ./go-plugins/gateway

# Upload to BSR
buf beta registry plugin push \
    --visibility public \
    --override-remote bufbuild.internal \
    --image bufbuild.internal/go-plugins/gateway:v2.27.0 \
    ./go-plugins/gateway
```

## Plugin Dependencies

The plugins form a dependency chain:

1. **Multi Plugin** (`go`) - Base plugin (no dependencies)
2. **gRPC Plugin** (`grpc`) - Depends on `go-plugins/go:v1.36.6`
3. **Gateway Plugin** (`gateway`) - Depends on both `go-plugins/go:v1.36.6` and `go-plugins/grpc:v1.5.1`

This structure allows the BSR to generate separate Go modules for each plugin while maintaining proper import relationships.
