# tailscale-docker-client
This Dockerfile creates a Docker container that connects to a self-hosted Tailscale network like Headscale. The container installs the necessary dependencies (Tailscale, iptables, etc.) and configures Tailscale to connect to the provided Tailnet server with an authentication key.

# Build the Docker Image

To build the Docker image, use the following command:

```bash
docker build -t tailscale-docker-client .
```

# Run with docker

To run the Docker container directly, use the following command:
```bash
docker run -d \
  --name tailscale-docker-client \
  --cap-add NET_ADMIN \
  --device /dev/net/tun \
  -e TAILSCALE_KEY=<AUTH_KEY> \
  -e TAILSCALE_SERVER_URL=<SERVER_URL> \
  -e TAILSCALE_HOSTNAME=<HOSTNAME> \
  -v $(pwd)/tailscale-client/:/tailscale/ \
  tailscale-docker-client
```
# Run with docker compose

create a docker-compose.yml 
```yml
services:
  tailscale-docker-client:
    image: tailscale-docker-client
    container_name: tailscale-docker-client
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    environment:
      TAILSCALE_KEY: <AUTH_KEY>
      TAILSCALE_SERVER_URL: <SERVER_URL}
      TAILSCALE_HOSTNAME: <HOSTNAME}     
    volumes:
      - ./tailscale-client/:/tailscale/

```
Then, start the container with:
```bash
docker-compose up -d
```
### What is `/dev/net/tun` ?

- **Tunnel Network Interface**: `/dev/net/tun` is a special device used to create tunnel-type network interfaces (TUN/TAP). These interfaces are often used for VPNs and other types of virtual networks.

- **Tailscale**: For Tailscale to function properly, it needs access to a TUN/TAP network interface to establish VPN connections. Without this interface, Tailscale cannot create the necessary tunnels to connect to your Tailnet network.

### Why is `NET_ADMIN` Necessary?

- **Network Administration**: `NET_ADMIN` is a Linux capability that grants a process the ability to manage network configurations. This includes tasks such as setting up IP addresses, modifying routing tables, and managing network interfaces.

- **Tailscale**: Tailscale requires `NET_ADMIN` to configure network interfaces and manage firewall rules needed for establishing VPN connections. Without this capability, Tailscale would be unable to perform necessary network operations for connecting to your Tailnet network.

### Why is the Volume /tailscale/state Useful?

The volume mounted at /tailscale/state is used to persist Tailscale’s state information across container restarts. This state includes crucial data such as authentication tokens and network configurations.