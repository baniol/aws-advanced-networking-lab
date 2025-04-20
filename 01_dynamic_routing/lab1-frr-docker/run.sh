#!/bin/bash

# Clean up any existing resources first
echo "Cleaning up any existing resources..."
docker compose down --volumes --remove-orphans
docker network prune -f
sudo systemctl restart docker
sleep 2

# Clean and recreate directories for FRR configurations
sudo rm -rf frr-configs
mkdir -p frr-configs/router{1,2,3,4}

# Create FRR configuration for Router 1 (AS 65000)
cat > frr-configs/router1/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname router1
no ipv6 forwarding
!
interface lo
 ip address 1.1.1.1/32
!
router bgp 65000
 bgp router-id 1.1.1.1
 bgp log-neighbor-changes
 neighbor 172.30.0.2 remote-as 65001
 neighbor 172.30.0.3 remote-as 65002
 neighbor 172.30.0.4 remote-as 65003
 !
 address-family ipv4 unicast
  redistribute connected
  network 1.1.1.1/32
  neighbor 172.30.0.2 activate
  neighbor 172.30.0.2 soft-reconfiguration inbound
  neighbor 172.30.0.2 route-map ACCEPT in
  neighbor 172.30.0.2 route-map ACCEPT out
  neighbor 172.30.0.3 activate
  neighbor 172.30.0.3 soft-reconfiguration inbound
  neighbor 172.30.0.3 route-map ACCEPT in
  neighbor 172.30.0.3 route-map ACCEPT out
  neighbor 172.30.0.4 activate
  neighbor 172.30.0.4 soft-reconfiguration inbound
  neighbor 172.30.0.4 route-map ACCEPT in
  neighbor 172.30.0.4 route-map ACCEPT out
 exit-address-family
!
route-map ACCEPT permit 10
!
line vty
!
EOF

# Create FRR configuration for Router 2 (AS 65001)
cat > frr-configs/router2/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname router2
no ipv6 forwarding
!
interface lo
 ip address 2.2.2.2/32
!
router bgp 65001
 bgp router-id 2.2.2.2
 bgp log-neighbor-changes
 neighbor 172.30.0.10 remote-as 65000
 !
 address-family ipv4 unicast
  redistribute connected
  network 2.2.2.2/32
  neighbor 172.30.0.10 activate
  neighbor 172.30.0.10 soft-reconfiguration inbound
  neighbor 172.30.0.10 route-map ACCEPT in
  neighbor 172.30.0.10 route-map ACCEPT out
 exit-address-family
!
route-map ACCEPT permit 10
!
line vty
!
EOF

# Create FRR configuration for Router 3 (AS 65002)
cat > frr-configs/router3/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname router3
no ipv6 forwarding
!
interface lo
 ip address 3.3.3.3/32
!
router bgp 65002
 bgp router-id 3.3.3.3
 bgp log-neighbor-changes
 neighbor 172.30.0.10 remote-as 65000
 !
 address-family ipv4 unicast
  redistribute connected
  network 3.3.3.3/32
  neighbor 172.30.0.10 activate
  neighbor 172.30.0.10 soft-reconfiguration inbound
  neighbor 172.30.0.10 route-map ACCEPT in
  neighbor 172.30.0.10 route-map ACCEPT out
 exit-address-family
!
route-map ACCEPT permit 10
!
line vty
!
EOF

# Create FRR configuration for Router 4 (AS 65003)
cat > frr-configs/router4/frr.conf << 'EOF'
frr version 8.1
frr defaults traditional
hostname router4
no ipv6 forwarding
!
interface lo
 ip address 4.4.4.4/32
!
router bgp 65003
 bgp router-id 4.4.4.4
 bgp log-neighbor-changes
 neighbor 172.30.0.10 remote-as 65000
 !
 address-family ipv4 unicast
  redistribute connected
  network 4.4.4.4/32
  neighbor 172.30.0.10 activate
  neighbor 172.30.0.10 soft-reconfiguration inbound
  neighbor 172.30.0.10 route-map ACCEPT in
  neighbor 172.30.0.10 route-map ACCEPT out
 exit-address-family
!
route-map ACCEPT permit 10
!
line vty
!
EOF

# Create daemons file to enable required FRR components
for router in router1 router2 router3 router4; do
  cat > frr-configs/$router/daemons << 'EOF'
# FRR daemons configuration
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
done

# Create vtysh.conf file for each router
for router in router1 router2 router3 router4; do
  cat > frr-configs/$router/vtysh.conf << EOF
!
hostname $router
!
EOF
done

# Set permissions
chmod -R 755 frr-configs
chmod 644 frr-configs/*/daemons
chmod 644 frr-configs/*/frr.conf
chmod 644 frr-configs/*/vtysh.conf

# Build and start the lab using docker compose
echo "Starting FRR BGP lab..."
docker compose up --build -d

echo "Lab is up and running!"
echo "To check BGP status on router1, run: docker exec -it router1 vtysh -c 'show ip bgp summary'"
echo "To access router CLI, run: docker exec -it <router_name> vtysh" 