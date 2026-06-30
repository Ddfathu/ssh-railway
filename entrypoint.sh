#!/bin/bash

# Ambil kredensial dari Environment Variable (Default jika kosong)
USER_NAME="${SSH_USER:-ddfathu}"
USER_PASS="${SSH_PASSWORD:-rahasia123}"
WS_PORT="${PORT:-8080}" # Railway otomatis memberikan port HTTP via variabel PORT

echo "[*] Mengonfigurasi User SSH..."
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
fi
echo "$USER_NAME:$USER_PASS" | chpasswd

echo "[*] Memulai OpenSSH Server di Port 22..."
/usr/sbin/sshd

echo "[*] Memulai WS Tunnel (Menghubungkan Port HTTP $WS_PORT ke SSH Port 22)..."
# Jalankan wstunnel sebagai penengah agar SSH bisa diakses via WebSocket HTTP
exec wstunnel server ws://0.0.0.0:$WS_PORT --restrictTo=127.0.0.1:22
