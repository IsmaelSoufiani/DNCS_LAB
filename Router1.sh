export DEBIAN_FRONTEND=noninteractive

sudo -i

ip link set enp0s8 name eth1 up
ip link set enp0s9 name eth2 up

ip addr add 10.0.1.1/30 dev eth2

ip link add link eth1 name eth1.10 type vlan id 10
ip link add link eth1 name eth1.20 type vlan id 20

ifconfig eth1.10 up
ifconfig eth1.20 up

ip addr add 192.168.0.10/23 dev eth1.10
ip addr add 192.168.2.20/23 dev eth1.20

ip route add 192.168.5.0/24 via 10.0.1.2

sysctl -w net.ipv4.ip_forward=1