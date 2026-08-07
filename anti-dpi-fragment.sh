#!/bin/bash
if [ "${ENABLE_FRAGMENT:-false}" = "true" ]; then
    echo "  [Module] Fragment: Active"
    iptables -t mangle -A OUTPUT -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1200 2>/dev/null || true
fi
