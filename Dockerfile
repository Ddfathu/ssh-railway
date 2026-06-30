FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies utama
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Konfigurasi runtime daemon SSH
RUN mkdir /var/run/sshd

# Download wstunnel terbaru (Arsitektur AMD64/x86_64 untuk server Railway)
RUN curl -L -o /usr/local/bin/wstunnel https://github.com/erebe/wstunnel/releases/latest/download/wstunnel_linux_amd64 && \
    chmod +x /usr/local/bin/wstunnel

# Salin script entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Port internal (Railway yang atur otomatis, tapi kita ekspos port standar)
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
