#!/bin/sh

# Script: Get list from URL or File and aplic rules.
# Author: Luis Gustavo Leal
#         www.luisgustavo.dev
# Obs:    Criar o diretorio /scripts

# Example URL
curl -s https://drive.vale.tech/scripts/firewall-List-IP-Portugal.txt -o /scripts/list_ips
echo "" >> /scripts/list_ips
#curl -s https://www.cloudflare.com/ips-v6 >> /dir/list_ips

# Examplo File
# 1.1.1.1
# 2.2.2.2
# 3.3.3.3

# Allow all traffic from Portugal IPs (no ports restriction)
###for ip in `cat /scripts/list_ips`; do ufw allow tcp from $ip comment 'No ports restriction to IP'; done

# Retrict to port 80 e 443 [ WEB ]
for ip in `cat /scripts/list_ips`; do ufw allow proto tcp from $ip to any port 80,443 comment '80,443 to Portugal'; done

# Restrict to port 22 [ SSH ]
for ip in `cat /scripts/list_ips`; do ufw allow proto tcp from $ip to any port 22 comment 'SSH to Portugal'; done

# Restrict to ports 10050 [ ZABBIX ]
for ip in `cat /scripts/list_ips`; do ufw allow proto tcp from $ip to any port 10050 comment 'Zabbix to Portugal'; done

# Restrict to ports 3306 [ MySQL ]
for ip in `cat /scripts/list_ips`; do ufw allow proto tcp from $ip to any port 3306 comment 'Zabbix to Portugal'; done

ufw reload > /dev/null
