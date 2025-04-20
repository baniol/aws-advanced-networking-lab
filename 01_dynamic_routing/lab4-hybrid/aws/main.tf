provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "hybrid-lab-vpc"
  }
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"
  
  tags = {
    Name = "hybrid-lab-private-subnet"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "${var.aws_region}a"
  
  tags = {
    Name = "hybrid-lab-public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "hybrid-lab-igw"
  }
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "hybrid-lab-public-rt"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "hybrid-lab-private-rt"
  }
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Create Virtual Private Gateway
resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "hybrid-lab-vgw"
  }
}

# Attach VGW to VPC
resource "aws_vpn_gateway_attachment" "vgw_attachment" {
  vpc_id         = aws_vpc.main.id
  vpn_gateway_id = aws_vpn_gateway.vgw.id
}

# Enable route propagation
resource "aws_vpn_gateway_route_propagation" "private" {
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = aws_route_table.private.id
}

# Create Customer Gateway
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = var.on_premises_asn
  ip_address = var.on_premises_ip
  type       = "ipsec.1"
  
  tags = {
    Name = "hybrid-lab-cgw"
  }
}

# Create VPN Connection
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = false
  
  tags = {
    Name = "hybrid-lab-vpn"
  }
}

# Create EC2 instance for testing
resource "aws_instance" "test_instance" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  
  tags = {
    Name = "hybrid-lab-test-instance"
  }
}

# Security group for test instance
resource "aws_security_group" "test_sg" {
  name        = "hybrid-lab-sg"
  description = "Allow traffic from on-premises network"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.on_premises_network_cidr]
  }
  
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.on_premises_network_cidr]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "hybrid-lab-sg"
  }
} 