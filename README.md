# DNCS-LAB - ISMAEL SOUFIANI



        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+


# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 309 and 474 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 186 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command


# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/


# Design
## 1. Define the addresses and the routes:

![Untitled Workspace](https://user-images.githubusercontent.com/82785025/129485706-fa180fc6-a1a9-4b63-b6eb-6ebcc4bfb530.jpg)


| Device | Interface | IP |
|--------|-----------|----|
|Router-1 | eth1.10 | 192.168.0.10/23 |
|Router-1 | eth1.20 | 192.168.2.20/23 |
|Router-1 | eth2 | 10.0.1.1/30 |
|Router-2 | eth1 | 192.168.5.2/24 |
|Router-2 | eth2 | 10.0.1.2/30 |
|Host-a | eth1 | 192.168.0.1/23 |
|Host-b | eth1 | 192.168.2.1/23 |
|Host-c | eth1 | 192.168.5.1/24 |


## 2. Configure every device with a script:

### Router-1:
```
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
```

### Router-2:
```
export DEBIAN_FRONTEND=noninteractive

sudo -i

ip link set enp0s8 name eth1 up
ip link set enp0s9 name eth2 up

ip addr add 10.0.1.2/30 dev eth2
ip addr add 192.168.5.2/24 dev eth1

ip route add 192.168.0.0/16 via 10.0.1.1


sysctl -w net.ipv4.ip_forward=1
```

### Switch:
```
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

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
```

### Host-a:
```
export DEBIAN_FRONTEND=noninteractive

sudo -i

ip link set enp0s8 name eth1 up

ip addr add 192.168.0.1/23 dev eth1

ip route add 10.0.1.0/30 via 192.168.0.10 dev eth1
ip route add 192.168.2.0/23 via 192.168.0.10 dev eth1
ip route add 192.168.5.0/24 via 192.168.0.10 dev eth1
```

### Host-b:
```
export DEBIAN_FRONTEND=noninteractive

sudo -i

ip link set enp0s8 name eth1 up

ip addr add 192.168.2.1/23 dev eth1

ip route add 10.0.1.0/30 via 192.168.2.20 dev eth1
ip route add 192.168.0.0/23 via 192.168.2.20 dev eth1
ip route add 192.168.5.0/24 via 192.168.2.20 dev eth1
```

### Host-c:
```
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
```
## 3. Modify the Vagrantfile:

### ROUTER-1:
```
config.vm.define "router-1" do |router1|
    router1.vm.box = "ubuntu/bionic64"
    router1.vm.hostname = "router-1"
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router1.vm.provision "shell", path: "Router1.sh"
    router1.vm.provider "virtualbox" do |vb|
      vb.memory = 256
```     
     
### ROUTER-2:
```
config.vm.define "router-2" do |router2|
    router2.vm.box = "ubuntu/bionic64"
    router2.vm.hostname = "router-2"
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router2.vm.provision "shell", path: "Router2.sh"
    router2.vm.provider "virtualbox" do |vb|
      vb.memory = 256
```

### SWITCH:
```
config.vm.define "switch" do |switch|
    switch.vm.box = "ubuntu/bionic64"
    switch.vm.hostname = "switch"
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
    switch.vm.provision "shell", path: "switch.sh"
    switch.vm.provider "virtualbox" do |vb|
      vb.memory = 256
```

### HOST-A:
```
config.vm.define "host-a" do |hosta|
    hosta.vm.box = "ubuntu/bionic64"
    hosta.vm.hostname = "host-a"
    hosta.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    hosta.vm.provision "shell", path: "Hosta.sh"
    hosta.vm.provider "virtualbox" do |vb|
      vb.memory = 256
 ```    
      
### HOST-B:
```
config.vm.define "host-b" do |hostb|
    hostb.vm.box = "ubuntu/bionic64"
    hostb.vm.hostname = "host-b"
    hostb.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
    hostb.vm.provision "shell", path: "Hostb.sh"
    hostb.vm.provider "virtualbox" do |vb|
      vb.memory = 256
 ```     
      
### HOST-C:
```
config.vm.define "host-c" do |hostc|
    hostc.vm.box = "ubuntu/bionic64"
    hostc.vm.hostname = "host-c"
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    hostc.vm.provision "shell", path: "Hostc.sh"
    hostc.vm.provider "virtualbox" do |vb|
      vb.memory = 512
```
## 4. Open the shell in the directory, the digit:
```
   Vagrant up
   ```
   
   To verify the connection between Host-a and Host-c:
   ```
   Vagrant ssh host-a
   ping 192.168.5.1
   ```
   To complete the requirements, in the Host-a or Host-b digit:
   ```
   curl 192.168.5.1
   ```
# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/

