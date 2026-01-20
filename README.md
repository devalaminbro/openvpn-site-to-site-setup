# 🔒 OpenVPN Site-to-Site Tunnel Automation

![OS](https://img.shields.io/badge/OS-Ubuntu%20%7C%20Debian-orange)
![Security](https://img.shields.io/badge/Encryption-AES--256--CBC-green)
![Topology](https://img.shields.io/badge/Topology-Site--to--Site-blue)

## 📖 Overview
Connecting two remote office networks securely over the public internet is a common requirement for System Administrators. Proprietary hardware VPNs (Cisco/Fortinet) are expensive.

This repository provides a **Production-Ready Bash Script** to deploy **OpenVPN** in Site-to-Site mode using a **Pre-Shared Static Key**. It bridges two remote LANs (e.g., `10.8.0.0/24`) so they can communicate as if they were in the same building.

## 🛠 Features
- ⚡ **Auto-Detection:** Script asks if the machine is "Server" (Head Office) or "Client" (Branch).
- 🔑 **Key Generation:** Automatically generates the `static.key` for encryption.
- 🛣️ **Routing:** Pushes routes automatically so Office A can ping Office B.
- 🛡️ **Hardening:** Enables IP Forwarding and UFW firewall rules automatically.
- 🔄 **KeepAlive:** Auto-reconnects if the internet connection drops.

## ⚙️ Architecture
- **Head Office (Server):** Listens on UDP 1194. Tunnel IP: `10.8.0.1`
- **Branch Office (Client):** Connects to Head Office IP. Tunnel IP: `10.8.0.2`

## 🚀 Deployment Guide

### Step 1: Clone Repository (On Both Servers)
```bash
git clone [https://github.com/devalaminbro/openvpn-site-to-site-setup.git](https://github.com/devalaminbro/openvpn-site-to-site-setup.git)
cd openvpn-site-to-site-setup
chmod +x deploy_vpn.sh

Step 2: Configure Head Office (Server)
Run the script and select Option 1:
sudo ./deploy_vpn.sh
# Select: 1 (Server)

After completion, it will generate a static.key file in /etc/openvpn/.

Step 3: Configure Branch Office (Client)
Copy the static.key from the Server to the Client's /etc/openvpn/ directory.

Run the script and select Option 2:
sudo ./deploy_vpn.sh
# Select: 2 (Client)
# Enter Server IP: [Public IP of Head Office]

Step 4: Verify Connection
Ping the other side of the tunnel:
ping 10.8.0.1  # From Client
ping 10.8.0.2  # From Server

Author: Sheikh Alamin Santo
Cloud Infrastructure Specialist & System Administrator
