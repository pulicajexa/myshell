#!/usr/bin/env bash

Green="\033[32m"
Font="\033[0m"
Red="\033[31m"

# 检查是否为root权限
root_need() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${Red}错误：该脚本需要以root权限运行！${Font}"
        exit 1
    fi
}

# 检测是否为OpenVZ架构
ovz_no() {
    if [[ -d "/proc/vz" ]]; then
        echo -e "${Red}您的VPS基于OpenVZ，不支持该脚本！${Font}"
        exit 1
    fi
}

# 添加swap
add_swap() {
    echo -e "${Green}请输入需要添加的swap大小，建议为内存的2倍！${Font}"
    read -p "请输入swap大小（MB）: " swapsize

    # 检查是否存在swapfile
    grep -q "swapfile" /etc/fstab

    # 如果不存在则创建swapfile
    if [ $? -ne 0 ]; then
        echo -e "${Green}未发现swapfile，正在创建swapfile...${Font}"
        fallocate -l ${swapsize}M /swapfile
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo '/swapfile none swap defaults 0 0' >> /etc/fstab
        echo -e "${Green}swap创建成功，当前swap信息：${Font}"
        cat /proc/swaps
        cat /proc/meminfo | grep Swap
    else
        echo -e "${Red}swapfile已存在，无法重复创建！请先删除当前swap再尝试。${Font}"
    fi
}

# 删除swap
del_swap() {
    # 检查是否存在swapfile
    grep -q "swapfile" /etc/fstab

    # 如果存在则删除swapfile
    if [ $? -eq 0 ]; then
        echo -e "${Green}发现swapfile，正在删除...${Font}"
        sed -i '/swapfile/d' /etc/fstab
        echo "3" > /proc/sys/vm/drop_caches
        swapoff -a
        rm -f /swapfile
        echo -e "${Green}swap已成功删除！${Font}"
    else
        echo -e "${Red}未发现swapfile，删除失败！${Font}"
    fi
}

# 主菜单
main() {
    root_need
    ovz_no
    clear
    echo -e "———————————————————————————————————————"
    echo -e "${Green}Linux VPS一键添加/删除swap脚本${Font}"
    echo -e "${Green}1. 添加swap${Font}"
    echo -e "${Green}2. 删除swap${Font}"
    echo -e "———————————————————————————————————————"
    read -p "请输入数字 [1-2]: " num
    case "$num" in
        1)
            add_swap
            ;;
        2)
            del_swap
            ;;
        *)
            clear
            echo -e "${Red}请输入有效的数字 [1-2]！${Font}"
            sleep 2s
            main
            ;;
    esac
}

main
