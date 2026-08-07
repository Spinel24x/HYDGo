#!/bin/bash
set -e

echo "╔════════════════════════════════════════╗"
echo "║     Xray Anti-DPI for Railway        ║"
echo "╚════════════════════════════════════════╝"
echo ""

CONFIG_FILE="${XRAY_CONFIG_PATH:-/app/config/config.json}"
MODULES_PATH="${XRAY_MODULES_PATH:-/app/modules}"
LOGS_PATH="${XRAY_LOGS_PATH:-/app/logs}"
PORT="${PORT:-443}"

echo "→ Configuration: $CONFIG_FILE"
echo "→ Modules Path: $MODULES_PATH"
echo "→ Port: $PORT"
echo "→ Log Level: ${LOG_LEVEL:-warning}"
echo ""

# به‌روزرسانی کانفیگ
if [ ! -f "$CONFIG_FILE" ]; then
    echo "✗ Config file not found!"
    exit 1
fi

echo "→ Updating configuration..."
jq --arg port "$PORT" '.inbounds[0].port = ($port | tonumber)' "$CONFIG_FILE" > /tmp/config.json
jq --arg loglevel "${LOG_LEVEL:-warning}" '.log.loglevel = $loglevel' /tmp/config.json > /tmp/config2.json

if grep -q "UUID_PLACEHOLDER" /tmp/config2.json; then
    echo "⚠ Generating temporary UUID..."
    NEW_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || date +%s)
    jq --arg uuid "$NEW_UUID" '.inbounds[0].settings.clients[0].id = $uuid' /tmp/config2.json > /tmp/config3.json
    mv /tmp/config3.json /tmp/config2.json
fi

mv /tmp/config2.json "$CONFIG_FILE"
echo "✓ Configuration updated"

# لود ماژول‌ها
echo "→ Loading anti-DPI modules..."
if [ -d "$MODULES_PATH" ]; then
    for module in "$MODULES_PATH"/*.sh; do
        if [ -f "$module" ]; then
            MODULE_NAME=$(basename "$module")
            echo "  ├─ Loading: $MODULE_NAME"
            source "$module" 2>/dev/null || echo "  │  ⚠ Failed"
        fi
    done
    echo "  └─ Done"
fi
echo ""

# اعتبارسنجی
echo "→ Validating configuration..."
if xray run -test -config "$CONFIG_FILE" 2>&1; then
    echo "✓ Configuration valid"
else
    echo "✗ Invalid configuration!"
    exit 1
fi

# اجرا
echo "→ Starting Xray..."
exec xray run -config "$CONFIG_FILE"
