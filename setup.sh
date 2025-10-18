
set -e

echo "===================================="
echo "      🧱 Dante SOCKS5 Installer"
echo "===================================="
echo


read -rp "Enter SOCKS username: " SOCKS_USER
read -rp "Enter SOCKS password: " SOCKS_PASS
read -rp "Enter SOCKS port [default: 1080]: " SOCKS_PORT
SOCKS_PORT=${SOCKS_PORT:-1080}

echo
echo ">>> Updating system packages..."
apt update -y >/dev/null

echo ">>> Installing Dante server..."
apt install -y dante-server >/dev/null

echo ">>> Detecting main network interface..."
INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n1)
echo ">>> Using interface: $INTERFACE"

echo ">>> Backing up existing config..."
if [ -f /etc/danted.conf ]; then
    mv /etc/danted.conf /etc/danted.conf.bak
fi

echo ">>> Writing new configuration to /etc/danted.conf..."
cat > /etc/danted.conf <<EOF
logoutput: /var/log/socks.log
internal: $INTERFACE port = $SOCKS_PORT
external: $INTERFACE
clientmethod: none
socksmethod: username
user.privileged: root
user.notprivileged: nobody

client pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: error connect disconnect
}
client block {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
}
socks pass {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        command: bind connect udpassociate
        log: error connect disconnect
        socksmethod: username
}
socks block {
        from: 0.0.0.0/0 to: 0.0.0.0/0
        log: connect error
}
EOF

echo ">>> Allowing Dante to write logs..."
SERVICE_FILE="/lib/systemd/system/danted.service"
if ! grep -q "ReadWriteDirectories=/var/log" "$SERVICE_FILE"; then
    echo "[Service]" >> "$SERVICE_FILE"
    echo "ReadWriteDirectories=/var/log" >> "$SERVICE_FILE"
fi

echo ">>> Creating proxy user..."
if ! id "$SOCKS_USER" &>/dev/null; then
    useradd -r "$SOCKS_USER"
fi
echo "$SOCKS_USER:$SOCKS_PASS" | chpasswd

echo ">>> Restarting Dante service..."
systemctl daemon-reload
systemctl enable danted >/dev/null
systemctl restart danted

echo ">>> Checking service status..."
systemctl status danted --no-pager | head -n 10

IP=$(hostname -I | awk '{print $1}')
echo
echo "===================================="
echo "✅ SOCKS5 Proxy is up and running!"
echo "------------------------------------"
echo "IP:   $IP"
echo "PORT: $SOCKS_PORT"
echo "USER: $SOCKS_USER"
echo "PASS: $SOCKS_PASS"
echo "===================================="
echo
echo ">>> Test your proxy with:"
echo "curl -x socks5://$SOCKS_USER:$SOCKS_PASS@$IP:$SOCKS_PORT -4 https://ip.hetzner.com"
echo
echo "Logs are available at: /var/log/socks.log"