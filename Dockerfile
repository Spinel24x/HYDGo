# ============================================
# Xray Anti-DPI - Railway Deployment
# All-in-one Dockerfile with extensible structure
# ============================================

FROM alpine:3.19 AS builder

# نصب پیش‌نیازهای build
RUN apk add --no-cache curl unzip bash ca-certificates

# دانلود Xray core
ARG XRAY_VERSION=1.8.23
RUN mkdir -p /tmp/xray && \
    ARCH=$(uname -m) && \
    case ${ARCH} in \
        x86_64) XRAY_ARCH="linux-64" ;; \
        aarch64) XRAY_ARCH="linux-arm64-v8a" ;; \
        armv7l) XRAY_ARCH="linux-arm32-v7a" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    echo "Downloading Xray ${XRAY_VERSION} for ${XRAY_ARCH}" && \
    curl -sSL -o /tmp/xray.zip \
    "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-${XRAY_ARCH}.zip" && \
    unzip -q /tmp/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray

# ============================================
# Stage نهایی
# ============================================
FROM alpine:3.19

# Metadata
LABEL maintainer="xray-anti-dpi"
LABEL description="Xray Core with Anti-DPI for Railway"
LABEL version="1.0.0"

# نصب runtime dependencies
RUN apk add --no-cache \
    bash \
    tzdata \
    ca-certificates \
    curl \
    jq \
    iptables \
    iproute2 \
    && cp /usr/share/zoneinfo/Asia/Tehran /etc/localtime \
    && echo "Asia/Tehran" > /etc/timezone

# کپی Xray binary
COPY --from=builder /usr/local/bin/xray /usr/local/bin/xray

# ایجاد ساختار پوشه‌ها
RUN mkdir -p /app/config \
    /app/scripts \
    /app/modules \
    /app/logs \
    /app/data \
    /etc/xray \
    /var/log/xray \
    && addgroup -g 1000 xray \
    && adduser -D -u 1000 -G xray xray \
    && chown -R xray:xray /app /etc/xray /var/log/xray

# ============================================
# کپی فایل‌های پروژه از main
# ============================================

# کانفیگ پیش‌فرض
COPY config.json /app/config/config.json
RUN ln -sf /app/config/config.json /etc/xray/config.json

# اسکریپت‌ها
COPY entrypoint.sh /app/scripts/entrypoint.sh
COPY healthcheck.sh /app/scripts/healthcheck.sh

# ماژول‌های Anti-DPI (همه فایل‌های modules رو کپی کن)
COPY modules/ /app/modules/

# تنظیم permissions
RUN chmod +x /app/scripts/*.sh \
    && chmod +x /app/modules/*.sh 2>/dev/null || true \
    && chown -R xray:xray /app

# ============================================
# Environment Variables
# ============================================
ENV XRAY_CONFIG_PATH=/app/config/config.json \
    XRAY_MODULES_PATH=/app/modules \
    XRAY_SCRIPTS_PATH=/app/scripts \
    XRAY_LOGS_PATH=/app/logs \
    RAILWAY_PORT=443 \
    LOG_LEVEL=warning \
    ENABLE_FRAGMENT=false \
    ENABLE_NOISE=false \
    ENABLE_PADDING=false \
    ENABLE_HEADER_MIX=false

# ============================================
# Health Check
# ============================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/scripts/healthcheck.sh || exit 1

# ============================================
# Runtime
# ============================================
USER xray
WORKDIR /app

# Ports
EXPOSE 443 80 8080

# Entrypoint
ENTRYPOINT ["/app/scripts/entrypoint.sh"]
