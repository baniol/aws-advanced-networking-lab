variable "region_a" {
  description = "AWS region A"
  type        = string
  default     = "us-east-1"
}

variable "region_b" {
  description = "AWS region B"
  type        = string
  default     = "us-west-2"
}

variable "vpc_a_cidr" {
  description = "CIDR block for VPC in region A"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_b_cidr" {
  description = "CIDR block for VPC in region B"
  type        = string
  default     = "10.1.0.0/16"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet in region A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for private subnet in region B"
  type        = string
  default     = "10.1.1.0/24"
}

variable "tgw_subnet_a_cidr" {
  description = "CIDR block for Transit Gateway subnet in region A"
  type        = string
  default     = "10.0.2.0/24"
}

variable "tgw_subnet_b_cidr" {
  description = "CIDR block for Transit Gateway subnet in region B"
  type        = string
  default     = "10.1.2.0/24"
}

variable "ami_id_region_a" {
  description = "AMI ID for EC2 instance in region A"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS in us-east-1
}

variable "ami_id_region_b" {
  description = "AMI ID for EC2 instance in region B"
  type        = string
  default     = "ami-0892d3c7ee96c0bf7"  # Ubuntu 20.04 LTS in us-west-2
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "your-key-name"  # Change this to your SSH key name
}

variable "vpn_bgp_peer_a" {
  description = "BGP peer IP for region A"
  type        = string
  default     = "169.254.10.1"  # Will be replaced with actual VPN BGP peer IP
}

variable "vpn_bgp_peer_b" {
  description = "BGP peer IP for region B"
  type        = string
  default     = "169.254.10.1"  # Will be replaced with actual VPN BGP peer IP
} 