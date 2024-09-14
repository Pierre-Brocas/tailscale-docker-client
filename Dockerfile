# Use the Alpine base image
FROM alpine:latest

# Install dependencies and Tailscale
RUN apk update && apk add --no-cache \
    curl \
    iptables \
    ip6tables \
    tailscale \
    ca-certificates \
    && mkdir -p /tailscale/state

# Set environment variables for Tailscale
ENV TAILSCALE_KEY=
ENV TAILSCALE_SERVER_URL=
ENV TAILSCALE_HOSTNAME=tailscale-container

# Run Tailscale with proper signal handling in JSON format
CMD ["/bin/sh", "-c", " \
    /usr/sbin/tailscaled --state=/tailscale/state & \
    TAILSCALED_PID=$! && \
    tailscale up --auth-key=\"$TAILSCALE_KEY\" --hostname=\"$TAILSCALE_HOSTNAME\" --login-server=\"$TAILSCALE_SERVER_URL\" && \
    trap 'tailscale down; kill $TAILSCALED_PID' SIGTERM SIGINT && \
    wait $TAILSCALED_PID"]
