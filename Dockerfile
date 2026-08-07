FROM alpine:3.19

# نصب dnscrypt-proxy
RUN apk add --no-cache curl && \
    curl -L -o /tmp/dnscrypt.tar.gz \
    "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.5/dnscrypt-proxy-linux_x86_64-2.1.5.tar.gz" && \
    tar xzf /tmp/dnscrypt.tar.gz -C /tmp && \
    mv /tmp/linux-x86_64/dnscrypt-proxy /usr/local/bin/ && \
    chmod +x /usr/local/bin/dnscrypt-proxy && \
    rm -rf /tmp/*

# ایجاد پوشه‌ها
RUN mkdir -p /app /etc/dnscrypt-proxy /var/log

# کپی کانفیگ
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 53 5353

ENTRYPOINT ["/app/entrypoint.sh"]
