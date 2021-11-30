#!/bin/sh

# Script: Get list from URL or File and aplic rules.
# Author: Luis Gustavo Leal 
#         www.luisgustavo.dev 

# Example URL
# curl -s https://www.cloudflare.com/ips-v4 -o /dir/list_ips
# echo "" >> /dir/list_ips
# curl -s https://www.cloudflare.com/ips-v6 >> /dir/list_ips

# Examplo File
# 1.1.1.1
# 2.2.2.2
# 3.3.3.3

# Allow all traffic from Portugal IPs (no ports restriction)
for ip in 'cat /dir/list_ips'; do ufw allow tcp from $ip comment 'No ports restriction to IP'; done

ufw reload > /dev/null

# Retrict to port 80 e 443 [ WEB ]
for ip in `cat /dir/list_ips`; do ufw allow proto tcp from $ip to any port 80,443 comment '80,443 to Portugal'; done

# Restrict to port 22 [ SSH ]
#for ip in `cat /dir/list_ips`; do ufw allow proto tcp from $ip to any port 22 comment 'SSH to Portugal'; done

# Restrict to ports 10050 [ ZABBIX ]
for ip in `cat /dir/list_ips`; do ufw allow proto tcp from $ip to any port 10050 comment 'Zabbix to Portugal'; done
