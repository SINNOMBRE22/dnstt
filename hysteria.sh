#!/usr/bin/env bash
# Hysteria Auto Installer - SINNOMBRE22

# ==================================================
# 📌 COLORES OFICIALES SINNOMBRE22
# ==================================================
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'; B='\033[0;34m'
M='\033[0;35m'; C='\033[0;36m'; W='\033[1;37m'; N='\033[0m'
BOLD='\033[1m'
ROJO="\e[31m"; BLANCO="\e[97m"; CYAN="\e[36m"; AMARILLO="\e[33m"; RESET="\e[0m"

# ==================================================
# 📌 LÍNEA OFICIAL
# ==================================================
LINEA="${ROJO}══════════════════════════ / / / ══════════════════════════${RESET}"

# ==================================================
# VARIABLES
# ==================================================
DOMAIN="tudominio.com"
EMAIL="admin@tudominio.com"
MYIP=$(curl -s https://api.ipify.org)

# ==================================================
# 📌 BARRA OFICIAL
# ==================================================
barra_progreso() {
echo -ne "${CYAN}ESPERANDO ${ROJO}["
for ((i=0;i<18;i++)); do
echo -ne "#"
sleep 0.05
done
echo -e "] ${G}OK${RESET}"
}

# ==================================================
# DEPENDENCIAS
# ==================================================
install_require () {
clear
echo -e "$LINEA"
echo -e "${BOLD}${BLANCO}                INSTALANDO DEPENDENCIAS                ${RESET}"
echo -e "$LINEA"

export DEBIAN_FRONTEND=noninteractive
apt update -y >/dev/null 2>&1
apt install -y curl wget gnupg openssl socat netcat jq unzip nano \
iptables iptables-persistent screen cron vnstat \
build-essential net-tools gnutls-bin python3 >/dev/null 2>&1

barra_progreso
echo -e "${G}✔ Dependencias instaladas correctamente${RESET}"
sleep 1
}

# ==================================================
# INSTALAR HYSTERIA
# ==================================================
install_hysteria(){
clear
echo -e "$LINEA"
echo -e "${BOLD}${BLANCO}                  INSTALANDO HYSTERIA                  ${RESET}"
echo -e "$LINEA"

wget -q -O install_server.sh https://raw.githubusercontent.com/apernet/hysteria/master/install_server.sh
chmod +x install_server.sh
./install_server.sh >/dev/null 2>&1

barra_progreso
echo -e "${G}✔ Hysteria instalado correctamente${RESET}"
sleep 1
}

# ==================================================
# SSL
# ==================================================
install_letsencrypt(){
clear
echo -e "$LINEA"
echo -e "${BOLD}${BLANCO}               CONFIGURANDO CERTIFICADO SSL               ${RESET}"
echo -e "$LINEA"

apt remove apache2 -y >/dev/null 2>&1

curl -s https://get.acme.sh | sh >/dev/null 2>&1
~/.acme.sh/acme.sh --register-account -m $EMAIL --server zerossl >/dev/null 2>&1
~/.acme.sh/acme.sh --issue -d "$DOMAIN" --standalone -k ec-256 >/dev/null 2>&1
~/.acme.sh/acme.sh --installcert -d "$DOMAIN" \
--fullchainpath /etc/hysteria/hysteria.crt \
--keypath /etc/hysteria/hysteria.key --ecc >/dev/null 2>&1

chmod 644 /etc/hysteria/hysteria.crt
chmod 600 /etc/hysteria/hysteria.key

barra_progreso
echo -e "${G}✔ Certificado SSL configurado${RESET}"
sleep 1
}

# ==================================================
# CONFIG HYSTERIA
# ==================================================
modify_hysteria(){
clear
echo -e "$LINEA"
echo -e "${BOLD}${BLANCO}                CONFIGURANDO HYSTERIA                ${RESET}"
echo -e "$LINEA"

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

barra_progreso
echo -e "${G}✔ Configuración aplicada${RESET}"
sleep 1
}

# ==================================================
# BBR
# ==================================================
installBBR() {
echo -e "$LINEA"
echo -e "${BOLD}${BLANCO}                     ACTIVANDO BBR                     ${RESET}"
echo -e "$LINEA"

cat >> /etc/sysctl.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sysctl -p >/dev/null 2>&1

barra_progreso
echo -e "${G}✔ BBR activado${RESET}"
sleep 1
}

# ==================================================
# FIREWALL
# ==================================================
install_firewall(){
clear
echo -e "$LINEA"
echo -e "${BOLD}${BLANCO}                CONFIGURANDO FIREWALL                ${RESET}"
echo -e "$LINEA"

INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)

iptables -t nat -A PREROUTING -i $INTERFACE -p udp --dport 20000:50000 -j DNAT --to-destination :1080
iptables -A INPUT -p udp --dport 1080 -j ACCEPT

iptables-save > /etc/iptables_rules.v4

barra_progreso
echo -e "${G}✔ Firewall configurado${RESET}"
sleep 1
}

# ==================================================
# FINAL
# ==================================================
start_service(){
clear
echo -e "$LINEA"
echo -e "${BOLD}${BLANCO}                 HYSTERIA INSTALADO                 ${RESET}"
echo -e "$LINEA"

echo
echo -e "${G}✔ Instalación completada correctamente${RESET}"
echo
echo -e "${CYAN}IP:${RESET} $MYIP"
echo -e "${CYAN}Puerto:${RESET} 1080"
echo -e "${CYAN}Dominio:${RESET} $DOMAIN"
echo -e "${CYAN}Password:${RESET} SINNOMBRE22"
echo
echo -e "${Y}⚠ Reiniciando servidor en 15 segundos...${RESET}"
sleep 15
reboot
}

# ==================================================
# EJECUCIÓN
# ==================================================
install_require
install_hysteria
install_letsencrypt
install_firewall
modify_hysteria
installBBR
start_service