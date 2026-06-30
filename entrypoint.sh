#!/bin/bash

USER_NAME="${SSH_USER:-ddfathu}"
USER_PASS="${SSH_PASSWORD:-123456}"
MAIN_PORT="${PORT:-8080}"

echo "[*] Mengonfigurasi User SSH..."
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
fi
echo "$USER_NAME:$USER_PASS" | chpasswd

echo "[*] Memulai OpenSSH Server di Port 22..."
/usr/sbin/sshd

echo "[*] Memulai wstunnel Gateway di Port $MAIN_PORT..."
# KOREKSI: Menggunakan argumen sertifikat yang valid dan memperbaiki restrict parameter
exec wstunnel server \
    --listen 0.0.0.0:$MAIN_PORT \
    --tlsSrvCert /etc/stunnel/server.crt \
    --tlsSrvKey /etc/stunnel/server.key \
    --restrictTo 127.0.0.1:22
