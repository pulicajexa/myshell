#!/bin/bash

# 安装 iptables
apt update
apt install iptables -y

# 读取用户输入的 IP 地址
read -p "请输入副IP: " ip2
read -p "请输入主IP: " ip1

# 检查 /etc/iptables 目录是否存在，不存在则创建
if [ ! -d /etc/iptables ]; then
    mkdir -p /etc/iptables
fi

# 设置 NAT 规则
iptables -t nat -C PREROUTING -p udp --dst $ip2 -j DNAT --to-destination $ip1 || iptables -t nat -A PREROUTING -p udp --dst $ip2 -j DNAT --to-destination $ip1
iptables-save > /etc/iptables/rules.v4

# 创建脚本文件
cat <<EOF >/usr/local/bin/UDP-rules.sh
#!/bin/bash
iptables -t nat -C PREROUTING -p udp --dst $ip2 -j DNAT --to-destination $ip1 || iptables -t nat -A PREROUTING -p udp --dst $ip2 -j DNAT --to-destination $ip1
iptables -t nat -C POSTROUTING -s $ip1 -j SNAT --to-source $ip1 || iptables -t nat -A POSTROUTING -s $ip1 -j SNAT --to-source $ip1
iptables-save > /etc/iptables/rules.v4
EOF

# 设置脚本可执行权限
chmod +x /usr/local/bin/UDP-rules.sh

# 创建 systemd 服务文件
cat <<EOF >/etc/systemd/system/UDP-rules.service
[Unit]
Description=Apply UDP NAT rules on boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/UDP-rules.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# 设置服务文件权限
chmod 644 /etc/systemd/system/UDP-rules.service

# 重新加载 systemd 服务
systemctl daemon-reload

# 启动并启用 UDP-rules 服务
systemctl start UDP-rules.service
systemctl enable UDP-rules.service
