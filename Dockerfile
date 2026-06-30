FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    openssl \
    sudo \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd /etc/stunnel

# KOREKSI: Membuat sertifikat privat (.key) dan publik (.crt) secara terpisah untuk wstunnel
RUN openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=ID/ST=Jakarta/L=Jakarta/O=RailwaySSH/CN=localhost" \
    -keyout /etc/stunnel/server.key -out /etc/stunnel/server.crt

# Download binary wstunnel terbaru
RUN curl -L -o /usr/local/bin/wstunnel https://github.com/erebe/wstunnel/releases/latest/download/wstunnel_linux_amd64 && \
    chmod +x /usr/local/bin/wstunnel

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
