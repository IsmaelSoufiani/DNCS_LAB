export DEBIAN_FRONTEND=noninteractive

sudo -i

ip link set enp0s8 name eth1 up
ip link set enp0s9 name eth2 up

ip addr add 10.0.1.2/30 dev eth2
ip addr add 192.168.5.2/24 dev eth1

ip route add 192.168.0.0/16 via 10.0.1.1


sysctl -w net.ipv4.ip_forward=1