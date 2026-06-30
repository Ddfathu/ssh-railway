FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    stunnel4 \
    openssl \
    sudo \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd /var/run/stunnel

RUN openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=ID/ST=Jakarta/L=Jakarta/O=RailwaySSH/CN=localhost" \
    -keyout /etc/stunnel/stunnel.pem  -out /etc/stunnel/stunnel.pem

RUN curl -L -o /usr/local/bin/wstunnel https://github.com/erebe/wstunnel/releases/latest/download/wstunnel_linux_amd64 && \
    chmod +x /usr/local/bin/wstunnel

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Kita ekspos 3 port fungsional langsung
EXPOSE 22
EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
