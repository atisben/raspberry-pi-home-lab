#!/bin/bash  
iptables -I DOCKER-USER -i wlx90de8088773b -o wlan0 -j ACCEPT  
iptables -t nat -C POSTROUTING -o wlan0 -j MASQUERADE || iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE  
iptables -C FORWARD -i wlan0 -o wlx90de8088773b -m state --state RELATED,ESTABLISHED -j ACCEPT || iptables -A FORWARD -i wlan0 -o wlx90de8088773b -m state --state RELATED,ESTABLISHED -j ACCEPT  
iptables -C FORWARD -i wlx90de8088773b -o wlan0 -j ACCEPT || iptables -A FORWARD -i wlx90de8088773b -o wlan0 -j ACCEPT  
iptables-save > /etc/iptables/rules.v4  
