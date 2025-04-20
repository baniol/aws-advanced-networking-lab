#!/bin/bash

# This script sets up the local environment for the hybrid connectivity lab
# It requires the AWS VPN configuration as input

if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-aws-vpn-config.xml>"
  exit 1
fi

VPN_CONFIG=$1

if [ ! -f "$VPN_CONFIG" ]; then
  echo "Error: VPN configuration file not found: $VPN_CONFIG"
  exit 1
fi

echo "Setting up the local environment using VPN configuration from: $VPN_CONFIG"

# Extract VPN tunnel endpoints from the XML config
TUNNEL1_IP=$(grep -o '<tunnel_outside_address>.*<ip_address>.*</ip_address>.*</tunnel_outside_address>' $VPN_CONFIG | head -1 | grep -o '<ip_address>.*</ip_address>' | sed 's/<ip_address>\(.*\)<\/ip_address>/\1/')
TUNNEL2_IP=$(grep -o '<tunnel_outside_address>.*<ip_address>.*</ip_address>.*</tunnel_outside_address>' $VPN_CONFIG | tail -1 | grep -o '<ip_address>.*</ip_address>' | sed 's/<ip_address>\(.*\)<\/ip_address>/\1/')

# Extract pre-shared keys
PSK1=$(grep -o '<ike>.*<pre_shared_key>.*</pre_shared_key>.*</ike>' $VPN_CONFIG | head -1 | grep -o '<pre_shared_key>.*</pre_shared_key>' | sed 's/<pre_shared_key>\(.*\)<\/pre_shared_key>/\1/')
PSK2=$(grep -o '<ike>.*<pre_shared_key>.*</pre_shared_key>.*</ike>' $VPN_CONFIG | tail -1 | grep -o '<pre_shared_key>.*</pre_shared_key>' | sed 's/<pre_shared_key>\(.*\)<\/pre_shared_key>/\1/')

# Extract BGP information
BGP_PEER1=$(grep -o '<tunnel_inside_address>.*<ip_address>.*</ip_address>.*</tunnel_inside_address>' $VPN_CONFIG | head -1 | grep -o '<ip_address>.*</ip_address>' | sed 's/<ip_address>\(.*\)<\/ip_address>/\1/')
BGP_PEER2=$(grep -o '<tunnel_inside_address>.*<ip_address>.*</ip_address>.*</tunnel_inside_address>' $VPN_CONFIG | tail -1 | grep -o '<ip_address>.*</ip_address>' | sed 's/<ip_address>\(.*\)<\/ip_address>/\1/')
AWS_ASN=$(grep -o '<bgp>.*<asn>.*</asn>.*</bgp>' $VPN_CONFIG | head -1 | grep -o '<asn>.*</asn>' | sed 's/<asn>\(.*\)<\/asn>/\1/')

echo "Extracted configuration:"
echo "Tunnel 1 IP: $TUNNEL1_IP"
echo "Tunnel 2 IP: $TUNNEL2_IP"
echo "BGP Peer 1: $BGP_PEER1"
echo "BGP Peer 2: $BGP_PEER2"
echo "AWS ASN: $AWS_ASN"

# Update ipsec.conf with actual tunnel IPs
sed -i "s/right=x.x.x.x/right=$TUNNEL1_IP/" ipsec.conf
sed -i "s/right=y.y.y.y/right=$TUNNEL2_IP/" ipsec.conf

# Update ipsec.secrets with the pre-shared keys
sed -i "s/your-psk-here-for-tunnel1/$PSK1/" ipsec.secrets
sed -i "s/your-psk-here-for-tunnel2/$PSK2/" ipsec.secrets

# Update FRR configuration with BGP peer IPs and ASN
sed -i "s/neighbor x.x.x.x remote-as 64512/neighbor $BGP_PEER1 remote-as $AWS_ASN/" frr.conf
sed -i "s/neighbor y.y.y.y remote-as 64512/neighbor $BGP_PEER2 remote-as $AWS_ASN/" frr.conf
sed -i "s/neighbor x.x.x.x description/neighbor $BGP_PEER1 description/" frr.conf
sed -i "s/neighbor y.y.y.y description/neighbor $BGP_PEER2 description/" frr.conf
sed -i "s/neighbor x.x.x.x activate/neighbor $BGP_PEER1 activate/" frr.conf
sed -i "s/neighbor y.y.y.y activate/neighbor $BGP_PEER2 activate/" frr.conf
sed -i "s/neighbor x.x.x.x route-map/neighbor $BGP_PEER1 route-map/" frr.conf
sed -i "s/neighbor y.y.y.y route-map/neighbor $BGP_PEER2 route-map/" frr.conf

echo "Configuration files updated successfully!"
echo "Run 'docker-compose up -d' to start the local environment." 