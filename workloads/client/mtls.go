package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"time"

	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"github.com/spiffe/go-spiffe/v2/workloadapi"
)

func main() {
	socketPath := "unix:///opt/spire/sockets/workload_api.sock"
        serverAddress := "server:443"
        ctx := context.Background()

	/*cli, err := workloadapi.New(ctx, workloadapi.WithAddr(socketPath))
	if err != nil {
		fmt.Printf("Err: %w\n", err)
	}
	svid, err := cli.FetchX509SVID(ctx)
	if err != nil {
		fmt.Printf("Err: %w\n", err)
	}
	fmt.Printf("Svid = %+v\n", svid.Certificates[0])
	return**/


	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()

	// Allowed SPIFFE ID
	serverID := spiffeid.RequireFromString("spiffe://example.org/server")

	// Create a TLS connection.
	// The client expects the server to present an SVID with the spiffeID: 'spiffe://example.org/server'
	//
	// An alternative when creating Dial is using `spiffetls.Dial` that uses environment variable `SPIFFE_ENDPOINT_SOCKET`
	conn, err := spiffetls.DialWithMode(ctx, "tcp", serverAddress,
		spiffetls.MTLSClientWithSourceOptions(
			tlsconfig.AuthorizeID(serverID),
			workloadapi.WithClientOptions(workloadapi.WithAddr(socketPath)),
		))
	if err != nil {
		fmt.Printf("unable to create TLS connection: %w", err)
		return
	}
	defer conn.Close()

	// Send a message to the server using the TLS connection
	fmt.Fprintf(conn, "Hello server\n")

	// Read server response
	status, err := bufio.NewReader(conn).ReadString('\n')
	if err != nil && err != io.EOF {
		fmt.Printf("unable to read server response: %w", err)
		return
	}
	fmt.Printf("Server says: %q", status)
	//certificate := conn.ConnectionState().PeerCertificates[0].raw
	//fmt.Printf("Raw cert: %w", certificate)
	time.Sleep(300 * time.Second)
	return
}
