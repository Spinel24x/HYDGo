FROM alpine:3.19

# نصب پیش‌نیازها
RUN apk add --no-cache curl bash

# دانلود و نصب dnscrypt-proxy
RUN curl -L -o /tmp/dnscrypt.tar.gz \
    "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.5/dnscrypt-proxy-linux_x86_64-2.1.5.tar.gz" && \
    tar xzf /tmp/dnscrypt.tar.gz -C /tmp && \
    mv /tmp/linux-x86_64/dnscrypt-proxy /usr/local/bin/dnscrypt-proxy && \
    chmod +x /usr/local/bin/dnscrypt-proxy && \
    rm -rf /tmp/*

# ایجاد پوشه‌ها
RUN mkdir -p /etc/dnscrypt-proxy /var/log

# کپی فایل‌ها
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# پورت‌ها
EXPOSE 53

# اجرا
ENTRYPOINT ["/entrypoint.sh"]
