# Lab 3: AWS Transit Gateway BGP Lab

This lab demonstrates how to set up BGP routing between AWS VPCs using Transit Gateway and EC2-based BGP routers.

## Architecture

```
  Region A                          Region B
+-----------+                     +-----------+
|           |                     |           |
|   VPC A   |                     |   VPC B   |
|           |                     |           |
+-----+-----+                     +-----+-----+
      |                                 |
      |                                 |
+-----+-----+    VPN with BGP    +-----+-----+
|           +-------------------+|           |
|  TGW A    |                   |  TGW B     |
|           +-------------------+|           |
+-----+-----+                     +-----+-----+
      |                                 |
      |                                 |
+-----+-----+                     +-----+-----+
|           |                     |           |
|  EC2 FRR  |                     |  EC2 FRR  |
| (AS 65001)|                     | (AS 65002)|
+-----------+                     +-----------+
```

## Components

- 2 AWS VPCs in different regions
- 2 Transit Gateways
- Site-to-Site VPN with BGP routing
- EC2 instances running FRR for BGP peering
- Private subnets for application workloads

## Prerequisites

- AWS account with permissions to create:
  - VPCs, Transit Gateways, VPN Connections
  - EC2 instances, Security Groups, IAM roles
- Terraform installed (v1.0+)
- AWS CLI configured
- Basic understanding of BGP and AWS networking

## Deployment

This lab uses Terraform to deploy all required infrastructure.

1. Initialize Terraform:

```bash
terraform init
```

2. Deploy the infrastructure:

```bash
terraform apply
```

The deployment will create the following resources:
- Network infrastructure (VPCs, subnets, route tables)
- Transit Gateways in each region
- Site-to-Site VPN connections with BGP
- EC2 instances with FRR pre-configured

## Exploring the Lab

### BGP Configuration

1. Connect to the EC2 instances:

```bash
# Region A
ssh -i your-key.pem ec2-user@<instance-a-ip>

# Region B
ssh -i your-key.pem ec2-user@<instance-b-ip>
```

2. Check BGP status:

```bash
sudo vtysh -c "show ip bgp summary"
```

3. Verify route propagation:

```bash
sudo vtysh -c "show ip route bgp"
```

### Testing Connectivity

1. Deploy test instances in each VPC
2. Test connectivity between VPCs via Transit Gateway
3. Monitor traffic flow using VPC Flow Logs

## Exercises

1. **Route Advertisement Control**
   - Modify Transit Gateway route tables
   - Configure BGP prefix lists to filter routes

2. **Path Manipulation**
   - Configure AS path prepending
   - Test failover scenarios

3. **VPN Redundancy**
   - Add a second VPN connection
   - Test high-availability configurations

4. **Transit Gateway Peering**
   - Implement Transit Gateway peering instead of VPN
   - Compare performance and routing options

## Cleanup

When finished, destroy the resources to avoid unnecessary costs:

```bash
terraform destroy
```

This will remove all resources created for this lab. 