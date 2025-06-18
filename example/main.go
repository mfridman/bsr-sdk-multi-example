package main

import (
	"context"
	"fmt"

	"bufbuild.internal/gen/go/acme/debug-gateway/go-plugins/gateway/v2/service1/v1/service1v1gateway"
	"bufbuild.internal/gen/go/acme/debug-gateway/go-plugins/gateway/v2/service2/v1/service2v1gateway"
	service1v1 "bufbuild.internal/gen/go/acme/debug-gateway/go-plugins/go/service1/v1"
	service2v1 "bufbuild.internal/gen/go/acme/debug-gateway/go-plugins/go/service2/v1"
	"bufbuild.internal/gen/go/acme/debug-gateway/go-plugins/grpc/service1/v1/service1v1grpc"
	"bufbuild.internal/gen/go/acme/debug-gateway/go-plugins/grpc/service2/v1/service2v1grpc"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	"google.golang.org/grpc"
)

func main() {
	ctx := context.Background()
	// Using gateway
	_ = service1v1gateway.RegisterServiceHandlerServer(ctx, runtime.NewServeMux(), service1v1grpc.UnimplementedServiceServer{})
	_ = service2v1gateway.RegisterServiceHandlerServer(ctx, runtime.NewServeMux(), service2v1grpc.UnimplementedServiceServer{})
	// Using gRPC
	_ = service1v1grpc.NewServiceClient(&grpc.ClientConn{})
	_ = service2v1grpc.NewServiceClient(&grpc.ClientConn{})
	// Using base types
	_ = service1v1.GetServiceRequest{}
	_ = service2v1.GetServiceRequest{}

	fmt.Println("Gateway and gRPC services registered successfully")
}
