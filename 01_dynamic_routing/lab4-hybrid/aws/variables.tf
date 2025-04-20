variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "on_premises_asn" {
  description = "BGP ASN for the on-premises network"
  type        = number
  default     = 65000
}

variable "on_premises_ip" {
  description = "Public IP address of the on-premises VPN endpoint"
  type        = string
  default     = "1.2.3.4"  # Replace with your actual public IP
}

variable "on_premises_network_cidr" {
  description = "CIDR block for the on-premises network"
  type        = string
  default     = "192.168.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 in us-east-1
} 