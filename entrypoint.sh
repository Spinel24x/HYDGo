#!/bin/bash
set -e

echo "========================================="
echo "  DNSCrypt Proxy  Starting"
echo "========================================="
echo ""

# شروع DNSCrypt
echo "→ Starting DNSCrypt Proxy..."
echo "→ Port: 53"
echo "→ Servers: cloudflare, google"
echo ""

exec dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
