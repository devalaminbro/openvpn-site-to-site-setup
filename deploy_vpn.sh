```bash
#!/bin/bash

# ============================================================
# OpenVPN Site-to-Site Auto Installer
# Author: Sheikh Alamin Santo
# Description: Connects two remote networks using Static Key
# ============================================================

# Color Codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   OpenVPN Site-to-Site Setup Wizard          ${NC}"
echo -e "${GREEN}==============================================${NC}"

# 1. Install OpenVPN
echo -e "${CYAN}[+] Installing OpenVPN...${NC}"
apt-get update -y
apt-get install -y openvpn ufw

# 2. Enable IP Forwarding
echo -e "${CYAN}[+] Enabling IP Forwarding...${NC}"
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# 3. Choose Role
echo ""
echo "Select Role for this Machine:"
echo "1) Head Office (Server)"
echo "2) Branch Office (Client)"
read -p "Enter Choice [1-2]: " ROLE

if [ "$ROLE" == "1" ]; then
    # --- SERVER CONFIGURATION ---
    echo -e "${GREEN}[+] Configuring as Head Office (Server)...${NC}"
    
    # Generate Static Key
    openvpn --genkey --secret /etc/openvpn/static.key
    echo -e "${CYAN}[+] Generated static.key at /etc/openvpn/static.key${NC}"
    echo -e "${CYAN}[!] IMPORTANT: Copy this key to the Client machine securely!${NC}"
    
    # Create Config
    cat > /etc/openvpn/server.conf <<EOF
dev tun
ifconfig 10.8.0.1 10.8.0.2
secret /etc/openvpn/static.key
cipher AES-256-CBC
keepalive 10 120
persist-key
persist-tun
status /var/log/openvpn-status.log
verb 3
EOF

    # Open Firewall
    ufw allow 1194/udp
    
    echo -e "${GREEN}[+] Server Configured. Starting Service...${NC}"
    systemctl start openvpn@server
    systemctl enable openvpn@server

elif [ "$ROLE" == "2" ]; then
    # --- CLIENT CONFIGURATION ---
    echo -e "${GREEN}[+] Configuring as Branch Office (Client)...${NC}"
    
    read -p "Enter Head Office Public IP: " SERVER_IP
    
    # Check if Key Exists
    if [ ! -f "/etc/openvpn/static.key" ]; then
        echo -e "\033[0;31m[Error] static.key not found in /etc/openvpn/!${NC}"
        echo "Please upload the key from the server first."
        exit 1
    fi
    
    # Create Config
    cat > /etc/openvpn/client.conf <<EOF
remote $SERVER_IP
dev tun
ifconfig 10.8.0.2 10.8.0.1
secret /etc/openvpn/static.key
cipher AES-256-CBC
keepalive 10 120
persist-key
persist-tun
verb 3
EOF

    echo -e "${GREEN}[+] Client Configured. Starting Service...${NC}"
    systemctl start openvpn@client
    systemctl enable openvpn@client

else
    echo "Invalid Selection."
    exit 1
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   VPN SETUP COMPLETE! 🚀                     ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo "Check status with: systemctl status openvpn@..."
