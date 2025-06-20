#!/bin/bash

set -e

GAI_CONF="/etc/gai.conf"
BACKUP_FILE="/etc/gai.conf.bak"

echo "[INFO] Backing up original $GAI_CONF to $BACKUP_FILE..."
sudo cp "$GAI_CONF" "$BACKUP_FILE"

echo "[INFO] Enabling IPv4 priority in $GAI_CONF..."

# 如果原文件中已存在对应项且被注释，取消注释；否则添加新行
if grep -q '^#precedence ::ffff:0:0/96  100' "$GAI_CONF"; then
    sudo sed -i 's/^#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/' "$GAI_CONF"
elif ! grep -q '^precedence ::ffff:0:0/96  100' "$GAI_CONF"; then
    echo 'precedence ::ffff:0:0/96  100' | sudo tee -a "$GAI_CONF" > /dev/null
fi

echo "[OK] IPv4 is now preferred over IPv6 for hostname resolution."
