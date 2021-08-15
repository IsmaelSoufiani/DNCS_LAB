export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

# Startup commands for switch go here

sudo -i

ovs-vsctl add-br switch

ip link set enp0s8 name eth1
ip link set enp0s9 name eth2
ip link set enp0s10 name eth3

ovs-vsctl add-port switch eth1
ovs-vsctl add-port switch eth2 tag="10"
ovs-vsctl add-port switch eth3 tag="20"

ip link set dev eth1 up
ip link set dev eth2 up
ip link set dev eth3 up