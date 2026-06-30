#!/bin/bash

USER_NAME="${SSH_USER:-ddfathu}"
USER_PASS="${SSH_PASSWORD:-123456}"

echo "[*] Mengonfigurasi User SSH..."
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
fi
echo "$USER_NAME:$USER_PASS" | chpasswd

echo "[*] Memulai OpenSSH Server di Port 22 (SSH Direct)..."
/usr/sbin/sshd

echo "[*] Memulai WS Tunnel di Port 80 (Khusus Payload WS Biasa)..."
wstunnel server ws://0.0.0.0:80 --restrictTo=127.0.0.1:22 &

echo "[*] Memulai Stunnel (TLS) di Port 443 (Khusus SNI Murni)..."
cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
foreground = yes
debug = 4

[ssh-ssl]
accept = 0.0.0.0:443
connect = 127.0.0.1:22
cert = /etc/stunnel/stunnel.pem
EOF
exec stunnel /etc/stunnel/stunnel.conf
