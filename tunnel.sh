#!/bin/bash

#variables
xray_ip=$(grep 'address' config.json | sed ':a;N;$!ba;s/\n//g' |sed 's/"//g'| sed 's/,//g' | awk '{print$2}') # This is a pretty bad way to find the remote ip . so if u can just paste the ip address of your VPS here
def_gate=$(ip r | grep 'default' | awk '{print$3}') # This will output your default gateway ip address . if command fails try finding the deault gateway ip by using 'ip r' command

ip tuntap add dev tun0 mode tun user tun2socks
ip addr add 10.0.0.1/24 dev tun0
ip addr add fdfe:dcba:9876::1/125 dev tun0
ip route add $xray_ip via $def_gate
ip link set tun0 up
ip -6 link set tun0 up
ip route add default dev tun0
ip -6 route add default dev tun0
chmod +x tun2socks
xray -c config.json > /dev/null &
sleep 5
./tun2socks -device tun://tun0 -proxy socks5://127.0.0.1:10808 # you can define the local socks5 port here 10808 is the default
ip tuntap del dev tun0 mode tun
ip route del $xray_ip via $def_gate
