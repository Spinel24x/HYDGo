#!/bin/bash
set -e

# ============================================
# Xray Anti-DPI Entrypoint
# ============================================

echo "╔════════════════════════════════════════╗"
echo "║     Xray Anti-DPI for Railway        ║"
echo "╚════════════════════════════════════════╝"
echo ""

# تنظیم مسیرها
CONFIG_FILE="${XRAY_CONFIG_PATH:-/app/config/config.json}"
MODULES_PATH="${XRAY_MODULES_PATH:-/app/modules}"
LOGS_PATH="${XRAY_LOGS_PATH:-/app/logs}"
PORT="${PORT:-$RAILWAY_PORT}"
PORT="${PORT:-443}"

echo "→ Configuration: $CONFIG_FILE"
echo "→ Modules Path: $MODULES_PATH"
echo "→ Logs Path: $LOGS_PATH"
echo "→ Port: $PORT"
echo "→ Log Level: ${LOG_LEVEL:-warning}"
echo ""

# ============================================
# به‌روزرسانی کانفیگ
# ============================================
update_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "✗ Config file not found at $CONFIG_FILE"
        exit 1
    fi
    
    echo "→ Updating configuration..."
    
    # به‌روزرسانی پورت
    jq --arg port "$PORT" '.inbounds[0].port = ($port | tonumber)' "$CONFIG_FILE" > /tmp/config.json
    
    # به‌روزرسانی سطح لاگ
    jq --arg loglevel "${LOG_LEVEL:-warning}" '.log.loglevel = $loglevel' /tmp/config.json > /tmp/config2.json
    
    # بررسی UUID
    if grep -q "UUID_PLACEHOLDER" /tmp/config2.json; then
        echo "⚠ Warning: Using placeholder UUID. Generate a real one!"
        NEW_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen 2>/dev/null || echo "$(date +%s)$RANDOM")
        jq --arg uuid "$NEW_UUID" '.inbounds[0].settings.clients[0].id = $uuid' /tmp/config2.json > /tmp/config3.json
        mv /tmp/config3.json /tmp/config2.json
        echo "  • Generated temporary UUID"
    fi
    
    mv /tmp/config2.json "$CONFIG_FILE"
    echo "✓ Configuration updated"
}

# ============================================
# لود ماژول‌ها
# ============================================
load_modules() {
    echo "→ Loading anti-DPI modules..."
    
    if [ -d "$MODULES_PATH" ]; then
        for module in "$MODULES_PATH"/*.sh; do
            if [ -f "$module" ]; then
                MODULE_NAME=$(basename "$module")
                echo "  ├─ Loading: $MODULE_NAME"
                source "$module" 2>/dev/null || {
                    echo "  │  ⚠ Failed to load $MODULE_NAME"
                    continue
                }
                echo "  │  ✓ Loaded successfully"
            fi
        done
        echo "  └─ All modules processed"
    else
        echo "  └─ No modules directory found"
    fi
    echo ""
}

# ============================================
# Validate Config
# ============================================
validate_config() {
    echo "→ Validating Xray configuration..."
    if xray run -test -config "$CONFIG_FILE" 2>&1; then
        echo "✓ Configuration is valid"
    else
        echo "✗ Invalid configuration!"
        cat "$CONFIG_FILE" | jq '.' 2>/dev/null || cat "$CONFIG_FILE"
        exit 1
    fi
    echo ""
}

# ============================================
# Main
# ============================================
main() {
    # به‌روزرسانی کانفیگ
    update_config
    
    # لود ماژول‌های سفارشی
    load_modules
    
    # اعتبارسنجی
    validate_config
    
    # نمایش کانفیگ نهایی
    echo "→ Final configuration:"
    jq '.' "$CONFIG_FILE" 2>/dev/null || cat "$CONFIG_FILE"
    echo ""
    
    # اجرای Xray
    echo "→ Starting Xray core..."
    exec xray run -config "$CONFIG_FILE"
}

# اجرا
main "$@"
