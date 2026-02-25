# 🚀 SlowDNS (DNSTT) Auto Installer

<p align="center">
  <img src="https://img.shields.io/badge/Ubuntu-22.04-orange?style=for-the-badge&logo=ubuntu">
  <img src="https://img.shields.io/badge/Architecture-x86_64-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Status-Stable-success?style=for-the-badge">
  <img src="https://img.shields.io/badge/Type-Auto%20Installer-black?style=for-the-badge">
</p>

Script profesional para la **instalación automática de SlowDNS (DNSTT Server)** en VPS Ubuntu.

Instala y configura múltiples servicios VPN junto con DNSTT de forma optimizada y lista para producción.

---

## 📦 Servicios Incluidos

- ✅ SSH
- ✅ SSL/TLS
- ✅ Dropbear
- ✅ V2Ray (WebSocket)
- ✅ Shadowsocks
- ✅ Hysteria
- ✅ Servicio personalizado adicional
- ✅ Servidor DNSTT (SlowDNS)

---

## 🖥️ Requisitos del Sistema

| Requisito | Detalle |
|-----------|----------|
| Sistema Operativo | Ubuntu Server |
| Versión Recomendada | 22.04 x86_64 |
| Compatible | 24.04 x86_64 |
| Acceso | Root |
| Estado del Sistema | VPS limpia o recién formateada |

⚠️ No recomendado:
- Ubuntu 20.04
- Ubuntu 18.04

---

## ⚙️ Instalación

Ejecuta como **root**:

```bash
rm -rf install
apt update
wget https://github.com/powermx/dnstt/raw/main/install
chmod +x install
./install --start
```

El script realiza automáticamente:

- 🔄 Actualización de paquetes
- 📦 Instalación de dependencias
- ⚙️ Configuración de servicios
- 🔐 Ajustes de firewall
- 🌐 Configuración del servidor DNSTT
- 🚀 Optimización básica del sistema

---

## 📡 ¿Qué es DNSTT?

DNSTT (DNS Tunnel Tool) permite encapsular tráfico dentro de consultas DNS, facilitando conexiones en redes restringidas o con inspección profunda de paquetes.

---

## 🛡️ Recomendaciones

- Usar VPS nueva sin otros scripts instalados.
- No mezclar con paneles de administración externos.
- Mantener el sistema actualizado.
- Configurar correctamente el dominio si se utiliza SSL.

---

## 👨‍💻 Créditos

- **@LaelsonCG** — Desarrollo principal  
- **@khaledagn** — Modificación  

📢 Telegram: https://t.me/vpnmx  

---

## ⭐ Soporte

Si el proyecto te resulta útil, considera darle una estrella ⭐ en GitHub.