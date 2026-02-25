#!/bin/bash
# Hysteria Auto Installer - SINNOMBRE22

DOMAIN="tudominio.com"   # ← CAMBIA ESTO
EMAIL="admin@tudominio.com"  # ← CAMBIA ESTO
MYIP=$(curl -s https://api.ipify.org)

timedatectl set-timezone Asia/Riyadh

install_require () {
clear
echo "Instalando dependencias..."
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y curl wget gnupg openssl socat netcat jq unzip nano \
iptables iptables-persistent screen cron neofetch vnstat \
build-essential net-tools gnutls-bin python3
}

install_hysteria(){
clear
echo "Instalando Hysteria..."
wget -O install_server.sh https://raw.githubusercontent.com/apernet/hysteria/master/install_server.sh
chmod +x install_server.sh
./install_server.sh
}

install_letsencrypt(){
clear
echo "Instalando certificado SSL..."
apt remove apache2 -y >/dev/null 2>&1

curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --register-account -m $EMAIL --server zerossl
~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d "$DOMAIN" \
--fullchainpath /etc/hysteria/hysteria.crt \
--keypath /etc/hysteria/hysteria.key --ecc

chmod 644 /etc/hysteria/hysteria.crt
chmod 600 /etc/hysteria/hysteria.key
}

modify_hysteria(){
clear
echo "Configurando Hysteria..."

cat > /etc/hysteria/config.json <<EOF
{
  "listen": ":1080",
  "cert": "/etc/hysteria/hysteria.crt",
  "key": "/etc/hysteria/hysteria.key",
  "up_mbps": 100,
  "down_mbps": 100,
  "disable_udp": false,
  "obfs": "SINNOMBRE22",
  "auth": {
    "mode": "password",
    "config": "SINNOMBRE22"
  }
}
EOF

chmod 600 /etc/hysteria/config.json
systemctl restart hysteria-server
}

installBBR() {
echo "Activando BBR..."
cat >> /etc/sysctl.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p
}

install_firewall(){
clear
echo "Configurando firewall..."

INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

iptables -t nat -A PREROUTING -i $INTERFACE -p udp --dport 20000:50000 -j DNAT --to-destination :1080
iptables -A INPUT -p udp --dport 1080 -j ACCEPT

iptables-save > /etc/iptables_rules.v4
}

install_rclocal(){

cat > /etc/systemd/system/sinnombre22.service <<EOF
[Unit]
Description=SINNOMBRE22 Service
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/rc.local
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/rc.local <<EOF
#!/bin/bash
iptables-restore < /etc/iptables_rules.v4
sysctl -p
systemctl restart hysteria-server
exit 0
EOF

chmod +x /etc/rc.local
systemctl daemon-reload
systemctl enable sinnombre22
systemctl start sinnombre22
}

start_service(){
clear
echo "Configurando renovación automática SSL..."

(crontab -l 2>/dev/null; echo "0 3 * * * ~/.acme.sh/acme.sh --cron --home ~/.acme.sh > /dev/null") | crontab -

systemctl restart hysteria-server

echo ""
echo "════════════════════════════════"
echo "     HYSTERIA INSTALADO ✔"
echo "        SINNOMBRE22"
echo "════════════════════════════════"
echo ""
echo "IP: $MYIP"
echo "Puerto: 1080"
echo "Dominio: $DOMAIN"
echo "Password: SINNOMBRE22"
echo ""
echo "Reiniciando servidor en 15 segundos..."
sleep 15
reboot
}

install_require
install_hysteria
install_letsencrypt
install_firewall
modify_hysteria
installBBR
install_rclocal
start_service