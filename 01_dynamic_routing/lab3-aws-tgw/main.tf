provider "aws" {
  region = var.region_a
  alias  = "region_a"
}

provider "aws" {
  region = var.region_b
  alias  = "region_b"
}

# VPC in Region A
resource "aws_vpc" "vpc_a" {
  provider   = aws.region_a
  cidr_block = var.vpc_a_cidr
  
  tags = {
    Name = "vpc-a"
  }
}

# Subnets in Region A
resource "aws_subnet" "private_subnet_a" {
  provider          = aws.region_a
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = "${var.region_a}a"
  
  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "tgw_subnet_a" {
  provider          = aws.region_a
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = var.tgw_subnet_a_cidr
  availability_zone = "${var.region_a}a"
  
  tags = {
    Name = "tgw-subnet-a"
  }
}

# VPC in Region B
resource "aws_vpc" "vpc_b" {
  provider   = aws.region_b
  cidr_block = var.vpc_b_cidr
  
  tags = {
    Name = "vpc-b"
  }
}

# Subnets in Region B
resource "aws_subnet" "private_subnet_b" {
  provider          = aws.region_b
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = "${var.region_b}a"
  
  tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_subnet" "tgw_subnet_b" {
  provider          = aws.region_b
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = var.tgw_subnet_b_cidr
  availability_zone = "${var.region_b}a"
  
  tags = {
    Name = "tgw-subnet-b"
  }
}

# Internet Gateways
resource "aws_internet_gateway" "igw_a" {
  provider = aws.region_a
  vpc_id   = aws_vpc.vpc_a.id
  
  tags = {
    Name = "igw-a"
  }
}

resource "aws_internet_gateway" "igw_b" {
  provider = aws.region_b
  vpc_id   = aws_vpc.vpc_b.id
  
  tags = {
    Name = "igw-b"
  }
}

# Transit Gateway in Region A
resource "aws_ec2_transit_gateway" "tgw_a" {
  provider    = aws.region_a
  description = "Transit Gateway A"
  
  tags = {
    Name = "tgw-a"
  }
}

# Transit Gateway in Region B
resource "aws_ec2_transit_gateway" "tgw_b" {
  provider    = aws.region_b
  description = "Transit Gateway B"
  
  tags = {
    Name = "tgw-b"
  }
}

# Transit Gateway VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_a" {
  provider           = aws.region_a
  subnet_ids         = [aws_subnet.tgw_subnet_a.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw_a.id
  vpc_id             = aws_vpc.vpc_a.id
  
  tags = {
    Name = "tgw-attachment-a"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_b" {
  provider           = aws.region_b
  subnet_ids         = [aws_subnet.tgw_subnet_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw_b.id
  vpc_id             = aws_vpc.vpc_b.id
  
  tags = {
    Name = "tgw-attachment-b"
  }
}

# Customer Gateway for TGW-A
resource "aws_customer_gateway" "cgw_a" {
  provider   = aws.region_a
  bgp_asn    = 65001
  ip_address = aws_instance.frr_instance_a.public_ip
  type       = "ipsec.1"
  
  tags = {
    Name = "cgw-a"
  }
}

# Customer Gateway for TGW-B
resource "aws_customer_gateway" "cgw_b" {
  provider   = aws.region_b
  bgp_asn    = 65002
  ip_address = aws_instance.frr_instance_b.public_ip
  type       = "ipsec.1"
  
  tags = {
    Name = "cgw-b"
  }
}

# Site-to-Site VPN Connection
resource "aws_vpn_connection" "vpn_a_to_b" {
  provider              = aws.region_a
  customer_gateway_id   = aws_customer_gateway.cgw_b.id
  transit_gateway_id    = aws_ec2_transit_gateway.tgw_a.id
  type                  = "ipsec.1"
  static_routes_only    = false
  
  tags = {
    Name = "vpn-a-to-b"
  }
}

resource "aws_vpn_connection" "vpn_b_to_a" {
  provider              = aws.region_b
  customer_gateway_id   = aws_customer_gateway.cgw_a.id
  transit_gateway_id    = aws_ec2_transit_gateway.tgw_b.id
  type                  = "ipsec.1"
  static_routes_only    = false
  
  tags = {
    Name = "vpn-b-to-a"
  }
}

# Security Group for FRR instances
resource "aws_security_group" "frr_sg_a" {
  provider    = aws.region_a
  name        = "frr-sg-a"
  description = "Security Group for FRR Instance A"
  vpc_id      = aws_vpc.vpc_a.id
  
  # Allow all IPsec traffic
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "frr_sg_b" {
  provider    = aws.region_b
  name        = "frr-sg-b"
  description = "Security Group for FRR Instance B"
  vpc_id      = aws_vpc.vpc_b.id
  
  # Allow all IPsec traffic
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instances with FRR
resource "aws_instance" "frr_instance_a" {
  provider      = aws.region_a
  ami           = var.ami_id_region_a
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet_a.id
  key_name      = var.key_name
  
  security_groups = [aws_security_group.frr_sg_a.id]
  
  user_data = <<-EOF
    #!/bin/bash
    # Install FRR
    sudo apt-get update -y
    sudo apt-get install -y frr frr-pythontools

    # Configure FRR
    sudo sed -i 's/^bgpd=no/bgpd=yes/' /etc/frr/daemons
    
    # Create FRR configuration
    cat > /etc/frr/frr.conf << 'FRRCFG'
    frr version 7.5
    frr defaults traditional
    hostname frr-a
    no ipv6 forwarding
    !
    interface lo
     ip address 172.16.0.1/32
    !
    router bgp 65001
     bgp router-id 172.16.0.1
     no bgp default ipv4-unicast
     bgp log-neighbor-changes
     neighbor ${var.vpn_bgp_peer_a} remote-as 65002
     !
     address-family ipv4 unicast
      network ${var.vpc_a_cidr}
      neighbor ${var.vpn_bgp_peer_a} activate
     exit-address-family
    !
    line vty
    !
    FRRCFG
    
    # Restart FRR
    sudo systemctl restart frr
  EOF
  
  tags = {
    Name = "frr-instance-a"
  }
}

resource "aws_instance" "frr_instance_b" {
  provider      = aws.region_b
  ami           = var.ami_id_region_b
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet_b.id
  key_name      = var.key_name
  
  security_groups = [aws_security_group.frr_sg_b.id]
  
  user_data = <<-EOF
    #!/bin/bash
    # Install FRR
    sudo apt-get update -y
    sudo apt-get install -y frr frr-pythontools

    # Configure FRR
    sudo sed -i 's/^bgpd=no/bgpd=yes/' /etc/frr/daemons
    
    # Create FRR configuration
    cat > /etc/frr/frr.conf << 'FRRCFG'
    frr version 7.5
    frr defaults traditional
    hostname frr-b
    no ipv6 forwarding
    !
    interface lo
     ip address 172.16.0.2/32
    !
    router bgp 65002
     bgp router-id 172.16.0.2
     no bgp default ipv4-unicast
     bgp log-neighbor-changes
     neighbor ${var.vpn_bgp_peer_b} remote-as 65001
     !
     address-family ipv4 unicast
      network ${var.vpc_b_cidr}
      neighbor ${var.vpn_bgp_peer_b} activate
     exit-address-family
    !
    line vty
    !
    FRRCFG
    
    # Restart FRR
    sudo systemctl restart frr
  EOF
  
  tags = {
    Name = "frr-instance-b"
  }
} 