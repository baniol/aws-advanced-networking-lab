#!/bin/bash

# Create configuration directories
mkdir -p configs/{rr1,rr2,bb1,client1,client2}

# Create FRR daemon configuration for all nodes
for node in rr1 rr2 bb1 client1 client2; do
  cat > configs/$node/daemons << 'EOF'
# FRR daemon configuration
zebra=yes
bgpd=yes
ospfd=no
ospf6d=no
ripd=no
ripngd=no
isisd=no
pimd=no
ldpd=no
nhrpd=no
eigrpd=no
babeld=no
sharpd=no
staticd=yes
pbrd=no
bfdd=no
fabricd=no
vrrpd=no
EOF
  chmod 644 configs/$node/daemons
done

# Create FRR configuration for RR1 (Route Reflector 1)
cat > configs/rr1/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname rr1
no ipv6 forwarding
!
interface lo
 ip address 10.0.0.1/32
!
interface eth1
 ip address 10.1.1.1/30
!
router bgp 65000
 bgp router-id 10.0.0.1
 no bgp default ipv4-unicast
 bgp log-neighbor-changes
 bgp cluster-id 1.1.1.1
 neighbor 10.1.1.2 remote-as 65000
 neighbor 10.1.1.2 description bb1
 !
 address-family ipv4 unicast
  network 10.0.0.1/32
  neighbor 10.1.1.2 activate
  neighbor 10.1.1.2 route-reflector-client
 exit-address-family
!
line vty
!
EOF
chmod 644 configs/rr1/frr.conf

# Create FRR configuration for RR2 (Route Reflector 2)
cat > configs/rr2/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname rr2
no ipv6 forwarding
!
interface lo
 ip address 10.0.0.2/32
!
interface eth1
 ip address 10.1.2.1/30
!
router bgp 65000
 bgp router-id 10.0.0.2
 no bgp default ipv4-unicast
 bgp log-neighbor-changes
 bgp cluster-id 2.2.2.2
 neighbor 10.1.2.2 remote-as 65000
 neighbor 10.1.2.2 description bb1
 !
 address-family ipv4 unicast
  network 10.0.0.2/32
  neighbor 10.1.2.2 activate
  neighbor 10.1.2.2 route-reflector-client
 exit-address-family
!
line vty
!
EOF
chmod 644 configs/rr2/frr.conf

# Create FRR configuration for BB1 (Backbone Router)
cat > configs/bb1/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname bb1
no ipv6 forwarding
!
interface lo
 ip address 10.0.0.3/32
!
interface eth1
 ip address 10.1.1.2/30
!
interface eth2
 ip address 10.1.2.2/30
!
interface eth3
 ip address 10.1.3.1/30
!
interface eth4
 ip address 10.1.4.1/30
!
ip prefix-list CLIENT1 permit 10.100.0.0/24
ip prefix-list CLIENT2 permit 10.200.0.0/24
!
route-map SET_COMMUNITY_CLIENT1 permit 10
 match ip address prefix-list CLIENT1
 set community 65000:100
!
route-map SET_COMMUNITY_CLIENT2 permit 10
 match ip address prefix-list CLIENT2
 set community 65000:200
!
router bgp 65000
 bgp router-id 10.0.0.3
 no bgp default ipv4-unicast
 bgp log-neighbor-changes
 neighbor 10.1.1.1 remote-as 65000
 neighbor 10.1.1.1 description rr1
 neighbor 10.1.2.1 remote-as 65000
 neighbor 10.1.2.1 description rr2
 neighbor 10.1.3.2 remote-as 65001
 neighbor 10.1.3.2 description client1
 neighbor 10.1.4.2 remote-as 65002
 neighbor 10.1.4.2 description client2
 !
 address-family ipv4 unicast
  network 10.0.0.3/32
  neighbor 10.1.1.1 activate
  neighbor 10.1.2.1 activate
  neighbor 10.1.3.2 activate
  neighbor 10.1.3.2 route-map SET_COMMUNITY_CLIENT1 in
  neighbor 10.1.4.2 activate
  neighbor 10.1.4.2 route-map SET_COMMUNITY_CLIENT2 in
 exit-address-family
!
line vty
!
EOF
chmod 644 configs/bb1/frr.conf

# Create FRR configuration for Client1
cat > configs/client1/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname client1
no ipv6 forwarding
!
interface lo
 ip address 10.0.0.4/32
!
interface eth1
 ip address 10.1.3.2/30
!
router bgp 65001
 bgp router-id 10.0.0.4
 no bgp default ipv4-unicast
 bgp log-neighbor-changes
 neighbor 10.1.3.1 remote-as 65000
 neighbor 10.1.3.1 description bb1
 !
 address-family ipv4 unicast
  network 10.0.0.4/32
  network 10.100.0.0/24
  neighbor 10.1.3.1 activate
 exit-address-family
!
line vty
!
EOF
chmod 644 configs/client1/frr.conf

# Create FRR configuration for Client2
cat > configs/client2/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname client2
no ipv6 forwarding
!
interface lo
 ip address 10.0.0.5/32
!
interface eth1
 ip address 10.1.4.2/30
!
router bgp 65002
 bgp router-id 10.0.0.5
 no bgp default ipv4-unicast
 bgp log-neighbor-changes
 neighbor 10.1.4.1 remote-as 65000
 neighbor 10.1.4.1 description bb1
 !
 address-family ipv4 unicast
  network 10.0.0.5/32
  network 10.200.0.0/24
  neighbor 10.1.4.1 activate
 exit-address-family
!
line vty
!
EOF
chmod 644 configs/client2/frr.conf

# Deploy the containerlab topology
echo "Deploying Containerlab topology..."
sudo containerlab deploy -t topology.yml

echo "Lab deployment complete!"
echo "To access the routers, use: docker exec -it clab-bgp-<node_name> vtysh"
echo "For example: docker exec -it clab-bgp-rr1 vtysh" 