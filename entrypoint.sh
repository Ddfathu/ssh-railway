#!/bin/bash

USER_NAME="${SSH_USER:-ddfathu}"
USER_PASS="${SSH_PASSWORD:-123456}"
MAIN_PORT="${PORT:-8080}" # Port utama yang dipantau Railway

echo "[*] Mengonfigurasi User SSH..."
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
fi
echo "$USER_NAME:$USER_PASS" | chpasswd

echo "[*] Memulai OpenSSH Server di Port 22..."
/usr/sbin/sshd

echo "[*] Memulai Stunnel (TLS) di Port 2222..."
cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
foreground = yes
debug = 4
[ssh-ssl]
accept = 127.0.0.1:2222
connect = 127.0.0.1:22
cert = /etc/stunnel/stunnel.pem
EOF
stunnel /etc/stunnel/stunnel.conf &

echo "[*] Memulai WS Tunnel (WebSocket) di Port 3333..."
wstunnel server ws://127.0.0.1:3333 --restrictTo=127.0.0.1:22 &

echo "[*] Mengonfigurasi HAProxy Load Balancer di Port Utama $MAIN_PORT..."
cat <<EOF > /etc/haproxy/haproxy.cfg
global
    log /dev/log local0

defaults
    log     global
    mode    tcp
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend main_gateway
    bind 0.0.0.0:$MAIN_PORT
    mode tcp
    
    # Cek apakah traffic berupa HTTP (WebSocket)
    acl is_http req_len ge 4
    acl is_http req_ssl_ver gt 0
    
    # Rute pemisahan traffic otomatis
    # Jika koneksi diawali TLS Handshake, arahkan ke Stunnel
    # Jika request HTTP biasa / Websocket, arahkan ke wstunnel
    # Sisanya masuk SSH Direct biasa
    tcp-request inspect-delay 2s
    tcp-request content accept if HTTP
    
    use_backend backend_stunnel if { req_ssl_hello_type 1 }
    use_backend backend_websocket if { req_len ge 4 }
    default_backend backend_ssh_direct

backend backend_ssh_direct
    mode tcp
    server sshd 127.0.0.1:22 check

backend backend_stunnel
    mode tcp
    server ssl_wrap 127.0.0.1:2222 check

backend backend_websocket
    mode tcp
    server ws_wrap 127.0.0.1:3333 check
EOF

echo "[*] Menjalankan HAProxy Gateway..."
exec haproxy -f /etc/haproxy/haproxy.cfg -db
