# Use the Alpine base image
FROM alpine:latest

# Install dependencies and Tailscale
RUN apk update && apk add --no-cache \
    curl \
    iptables \
    ip6tables \
    tailscale \
    ca-certificates

# Start the tailscaled daemon and run tailscale up in a command
CMD ["/bin/sh", "-c", "/usr/sbin/tailscaled & sleep 5 && tailscale up --auth-key=\"$TAILSCALE_KEY\" --hostname=\"tailscale-container\" --login-server=\"$TAILSCALE_SERVER_URL\" && tail -f /dev/null"]
