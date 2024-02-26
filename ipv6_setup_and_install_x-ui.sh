#!/bin/bash

# 默认设置
DEFAULT_DOMAIN="example.com"
DEFAULT_EMAIL="your_email@example.com"

# 询问用户输入域名和邮箱地址
read -p "请输入要申请 SSL 证书的域名（默认值：$DEFAULT_DOMAIN）: " DOMAIN
read -p "请输入 SSL 证书的邮箱地址（默认值：$DEFAULT_EMAIL）: " EMAIL

# 如果用户未输入任何内容，则使用默认设置
DOMAIN=${DOMAIN:-$DEFAULT_DOMAIN}
EMAIL=${EMAIL:-$DEFAULT_EMAIL}

# 设置防火墙规则
echo "设置防火墙规则..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F
iptables-save

# 更新系统
echo "更新系统..."
apt update -y

# 安装依赖
echo "安装依赖..."
apt install -y wget curl socat cron

# 安装 Warp
echo "安装 Warp..."
wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh

# 安装签发证书工具
echo "安装签发证书工具..."
curl https://get.acme.sh | sh

# 申请 SSL 证书，并下载到服务器目录
echo "申请 SSL 证书，并下载到服务器目录..."
~/.acme.sh/acme.sh --register-account -m $EMAIL
~/.acme.sh/acme.sh --issue -d $DOMAIN --standalone --listen-v6
~/.acme.sh/acme.sh --installcert -d $DOMAIN --key-file /root/private.key --fullchain-file /root/cert.crt

# 安装 X-UI
echo "正在安装 X-UI..."
wget -N --no-check-certificate https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh && bash install.sh

# 提示用户设置 X-UI 的用户名、密码和端口
echo "已完成设置防火墙规则"
echo "已完成部署 wget curl socat cron 依赖"
echo "已完成 warp 安装及设置"
echo "已完成申请 SSL 证书，并下载到服务器目录"
echo "已完成设置 X-UI 的用户名、密码和端口..."

echo "安装成功!"
