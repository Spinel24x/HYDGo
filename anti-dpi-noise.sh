#!/bin/bash
if [ "${ENABLE_NOISE:-false}" = "true" ]; then
    echo "  [Module] Noise: Active"
    tc qdisc add dev eth0 root netem delay 1ms 2ms 2>/dev/null || true
fi
