#!/bin/bash

# 检查是否有root权限
if [[ $EUID -ne 0 ]]; then
   echo "此脚本需要root权限，请使用sudo运行此脚本。" 
   exit 1
fi

# 询问用户要设置的新端口号
read -p "请输入新的SSH端口号: " new_port

# 验证端口号是否为有效的数字
if ! [[ "$new_port" =~ ^[0-9]+$ ]] || [ "$new_port" -le 0 ] || [ "$new_port" -gt 65535 ]; then
    echo "无效的端口号。请输入1到65535之间的数字。"
    exit 1
fi

# 修改sshd_config文件中的端口配置
sed -i "s/^#Port .*/Port $new_port/" /etc/ssh/sshd_config
sed -i "s/^Port .*/Port $new_port/" /etc/ssh/sshd_config

# 在防火墙中允许新的SSH端口
#ufw allow "$new_port"/tcp
#echo "已在防火墙中开放端口 $new_port。"

# 重启SSH服务以应用更改
systemctl restart ssh
echo "SSH服务已重启，新的SSH端口为 $new_port。"

# 提示用户测试新的端口连接
echo "请使用以下命令连接到新的SSH端口："
echo "ssh -p $new_port your_username@your_server_ip"

exit 0
