export DEBIAN_FRONTEND=noninteractive

sudo -i

ip link set enp0s8 name eth1 up

ip addr add 192.168.0.1/23 dev eth1

ip route add 10.0.1.0/30 via 192.168.0.10 dev eth1
ip route add 192.168.2.0/23 via 192.168.0.10 dev eth1
ip route add 192.168.5.0/24 via 192.168.0.10 dev eth1