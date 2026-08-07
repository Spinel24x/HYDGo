FROM alpine:3.19

RUN apk add --no-cache curl

RUN curl -L -o /tmp/dnscrypt.tar.gz \
    "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.5/dnscrypt-proxy-linux_x86_64-2.1.5.tar.gz" && \
    tar xzf /tmp/dnscrypt.tar.gz -C /tmp && \
    mv /tmp/linux-x86_64/dnscrypt-proxy /usr/local/bin/dnscrypt-proxy && \
    chmod +x /usr/local/bin/dnscrypt-proxy && \
    rm -rf /tmp/*

RUN mkdir -p /etc/dnscrypt-proxy /var/log

COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

EXPOSE 53

CMD ["dnscrypt-proxy", "-config", "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"]
