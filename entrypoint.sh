#!/bin/bash
set -e

echo "╔════════════════════════════════════════╗"
echo "║        DNSCrypt Proxy on Railway      ║"
echo "╚════════════════════════════════════════╝"
echo ""

# ساخت فایل blocked names (اختیاری)
cat > /etc/dnscrypt-proxy/blocked-names.txt << 'EOF'
*.doubleclick.net
*.google-analytics.com
*.facebook.com
EOF

echo "→ Starting DNSCrypt..."
echo "  • Port: 53 (TCP)"
echo "  • Servers: cloudflare, google, quad9"
echo "  • Cache: enabled"
echo ""

# اجرای DNSCrypt
exec dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
