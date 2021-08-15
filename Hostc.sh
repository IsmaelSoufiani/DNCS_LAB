export DEBIAN_FRONTEND=noninteractive

sudo -i

apt-get update
apt-get -y install docker.io
systemctl start docker
systemctl enable docker

docker pull dustnic82/nginx-test
docker run --name nginx -p 80:80 -d dustnic82/nginx-test

ip link set enp0s8 name eth1 up
ip addr add 192.168.5.1/24 dev eth1

ip route add 10.0.1.0/30 via 192.168.5.2 dev eth1
ip route add 192.168.0.0/23 via 192.168.5.2 dev eth1
ip route add 192.168.2.0/23 via 192.168.5.2 dev eth1