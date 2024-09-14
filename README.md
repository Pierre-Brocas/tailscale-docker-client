# tailscale-docker-client
This Dockerfile creates a Docker container that connects to a self-hosted Tailscale network like Headscale. The container installs the necessary dependencies (Tailscale, iptables, etc.) and configures Tailscale to connect to the provided Tailnet server with an authentication key.

# Build the Docker Image

To build the Docker image, use the following command:

```bash
docker build -t tailscale-docker-client .
```

# Run with docker

To run the Docker container directly, use the following command:
```
docker run -d \
  --name tailscale-container \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  -e TAILSCALE_KEY=<your_auth_key> \
  -e TAILSCALE_SERVER_URL=<your_tailscale_server_url> \
  tailscale-container
```
# Run with docker compose

create a docker-compose.yml 
```
services:
  tailscale:
    image: tailscale-container
    container_name: tailscale-container
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    environment:
      - TAILSCALE_KEY=<y
      our_auth_key>
      - TAILSCALE_SERVER_URL=<your_tailscale_server_url>
```
Then, start the container with:
```
docker-compose up -d
```
### Why is `/dev/net/tun` Necessary?

- **Tunnel Network Interface**: `/dev/net/tun` is a special device used to create tunnel-type network interfaces (TUN/TAP). These interfaces are often used for VPNs and other types of virtual networks.

- **Tailscale**: For Tailscale to function properly, it needs access to a TUN/TAP network interface to establish VPN connections. Without this interface, Tailscale cannot create the necessary tunnels to connect to your Tailnet network.

### Why is `NET_ADMIN` Necessary?

- **Network Administration**: `NET_ADMIN` is a Linux capability that grants a process the ability to manage network configurations. This includes tasks such as setting up IP addresses, modifying routing tables, and managing network interfaces.

- **Tailscale**: Tailscale requires `NET_ADMIN` to configure network interfaces and manage firewall rules needed for establishing VPN connections. Without this capability, Tailscale would be unable to perform necessary network operations for connecting to your Tailnet network.
