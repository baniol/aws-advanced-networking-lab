output "vpn_connection_id" {
  description = "ID of the VPN connection"
  value       = aws_vpn_connection.main.id
}

output "vpn_tunnel1_address" {
  description = "IP address of the first VPN tunnel"
  value       = aws_vpn_connection.main.tunnel1_address
}

output "vpn_tunnel2_address" {
  description = "IP address of the second VPN tunnel"
  value       = aws_vpn_connection.main.tunnel2_address
}

output "vpn_tunnel1_bgp_asn" {
  description = "BGP ASN of the first VPN tunnel"
  value       = aws_vpn_connection.main.tunnel1_bgp_asn
}

output "vpn_tunnel1_bgp_ip" {
  description = "BGP IP address of the first VPN tunnel"
  value       = aws_vpn_connection.main.tunnel1_bgp_ip
}

output "vpn_tunnel2_bgp_asn" {
  description = "BGP ASN of the second VPN tunnel"
  value       = aws_vpn_connection.main.tunnel2_bgp_asn
}

output "vpn_tunnel2_bgp_ip" {
  description = "BGP IP address of the second VPN tunnel"
  value       = aws_vpn_connection.main.tunnel2_bgp_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "test_instance_private_ip" {
  description = "Private IP address of the test instance"
  value       = aws_instance.test_instance.private_ip
} 