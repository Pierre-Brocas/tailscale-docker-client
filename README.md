# Tailscale Docker client

This Dockerfile creates a Docker container that connects to a self-hosted Tailscale network like [Headscale](https://github.com/juanfont/headscale).

# What's inside the container

This container is composed of an Alpine image on wich is installed a [Tailscale](https://tailscale.com) client with the necessary dependencies.
The container start tailscale and connect to the configured server.
When the container is shut down, the tailscale link is properly shutdown.

The intended use of this container is to provide access to the tailnet network to another container via the ``network_mode: container:tailscale-docker-client`` directive in docker compose.

# Docker compose example

## Use case

This example setup is designed to run a web service (via Caddy) over a Tailscale or Headscale VPN network. The Tailscale client (headscale-docker-client) handles the VPN connection, while Caddy serves web traffic or proxies requests over this VPN. The network mode ensures that Caddy’s traffic is securely routed through the Tailscale VPN, and not exposed to the public internet.

## How it works

Tailscale Client (headscale-docker-client):

* This container connects to a Tailscale or Headscale network using the specified authentication key, server URL, and hostname. It sets up a VPN connection and creates a secure, private network interface using the TUN device.
* By using the volume ``./tailscale-client/``, the Tailscale client persists its configuration across container restarts. This allows the container to reconnect to the VPN using the same identity and settings even after being stopped.

Caddy Server (caddy):

* Caddy is configured to use the network interface of the headscale-docker-client via the network_mode: container:tailscale-docker-client. This allows Caddy to serve content or act as a reverse proxy over the VPN network established by Tailscale.
* Since Caddy is running in the same network namespace as the Tailscale client, any web traffic it handles will be routed over the secure Tailscale VPN. This is particularly useful for exposing services securely over Tailscale without exposing them to the public internet.

## How to use it

create a docker-compose.yml

```yml
services:
  headscale-docker-client:
    image: ghcr.io/pierre-brocas/tailscale-docker-client:latest
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
  caddy:
    image: caddy:latest
    network_mode: container:tailscale-docker-client
    depends_on:
      headscale-docker-client:
        condition: service_started
    restart: unless-stopped
```

Then, start the container with:

```bash
docker-compose up -d
```

# Environment variables

The environment variables in the configuration are used to customize the Tailscale client:

* **TAILSCALE_KEY**: The authentication key used to join the Tailscale network.
* **TAILSCALE_SERVER_URL**: The URL of the Tailscale or Headscale server that the client connects to.
* **TAILSCALE_HOSTNAME**: The hostname that identifies the Tailscale client on the network.

### What is `/dev/net/tun` ?

- **Tunnel Network Interface**: `/dev/net/tun` is a special device used to create tunnel-type network interfaces (TUN/TAP). These interfaces are often used for VPNs and other types of virtual networks.
- **Tailscale**: For Tailscale to function properly, it needs access to a TUN/TAP network interface to establish VPN connections. Without this interface, Tailscale cannot create the necessary tunnels to connect to your Tailnet network.

### Why is `NET_ADMIN` Necessary?

- **Network Administration**: `NET_ADMIN` is a Linux capability that grants a process the ability to manage network configurations. This includes tasks such as setting up IP addresses, modifying routing tables, and managing network interfaces.
- **Tailscale**: Tailscale requires `NET_ADMIN` to configure network interfaces and manage firewall rules needed for establishing VPN connections. Without this capability, Tailscale would be unable to perform necessary network operations for connecting to your Tailnet network.

### Why is the Volume **/tailscale/state** Useful?

The volume mounted at ``/tailscale/state`` is used to persist Tailscale’s state information across container restarts. This state includes crucial data such as authentication tokens and network configurations.
