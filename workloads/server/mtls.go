package main

import (
	"bufio"
	"context"
	"fmt"
	"net"

	"github.com/spiffe/go-spiffe/v2/spiffetls"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"github.com/spiffe/go-spiffe/v2/workloadapi"
)

func main() {
	socketPath := "unix:///opt/spire/sockets/workload_api.sock"
        serverAddress := "0.0.0.0:443"
        ctx := context.Background()
	listener, err := spiffetls.ListenWithMode(ctx, "tcp", serverAddress, spiffetls.MTLSServerWithSourceOptions(tlsconfig.AuthorizeAny(), workloadapi.WithClientOptions(workloadapi.WithAddr(socketPath))))
	if err != nil {
                fmt.Printf("Listen error! %w\n", err)
                return
        }
        // Handle connections
	for {
		conn, err := listener.Accept()
		if err != nil {
                        fmt.Printf("Accept error! %w\n", err)
			return
		}
		go handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	defer conn.Close()

	// Read incoming data into buffer
	req, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil {
		fmt.Printf("Read error! %w\n", err)
		return
	}
	fmt.Printf("Client says: %q", req)

	// Send a response back to the client
	if _, err = conn.Write([]byte("Hello client\n")); err != nil {
		fmt.Printf("Write error! %w\n", err)
		return
	}
}
