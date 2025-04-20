# Lab 4: Hybrid BGP Connectivity (On-premises to AWS)

This lab demonstrates how to establish BGP connectivity between a simulated on-premises environment (using Docker containers) and AWS Virtual Private Gateway.

## Architecture

```
                AWS
+--------------------------------------+
|                                      |
|   +------------+     +----------+    |
|   |            |     |          |    |
|   |    VPC     +-----+   VGW    |    |
|   |            |     |          |    |
|   +------------+     +----+-----+    |
|                           |          |
+---------------------------|----------+
                            |
                            | VPN with BGP
                            |
                            |
+---------------------------|----------+
|                           |          |
|                      +----+-----+    |
|                      |          |    |
|                      |   VPN    |    |
|                      | Gateway  |    |
|                      +----+-----+    |
|                           |          |
|                      +----+-----+    |
|   +------------+     |          |    |
|   |   Local    |     |   FRR    |    |
|   |  Network   +-----+  Router  |    |
|   |            |     |          |    |
|   +------------+     +----------+    |
|                                      |
|             Local Environment        |
|         (Docker/Containerlab)        |
+--------------------------------------+
```

## Components

- AWS Virtual Private Gateway (VGW) with BGP support
- VPC with private subnets
- Simulated on-premises environment using Docker:
  - FRR router for IPsec VPN and BGP
  - Local network with test containers
  - Strongswan for IPsec VPN

## Prerequisites

- AWS account with permissions to create VPCs, VPNs, etc.
- Docker and Docker Compose installed locally
- Basic understanding of BGP, VPNs, and AWS networking
- AWS CLI configured

## Setup Instructions

This lab consists of two parts:
1. AWS resources deployment (using Terraform or CloudFormation)
2. Local Docker environment setup

### Part 1: AWS Setup

1. Deploy the AWS resources:

```bash
cd aws
terraform init
terraform apply
```

This will create:
- VPC with private subnets
- Virtual Private Gateway (VGW)
- Customer Gateway pointing to your local environment
- Site-to-Site VPN with BGP enabled

2. Retrieve the VPN configuration from AWS Console or CLI:

```bash
aws ec2 describe-vpn-connections --vpn-connection-ids <vpn-id> --query 'VpnConnections[0].CustomerGatewayConfiguration' --output text > vpn-config.xml
```

3. Extract the IPsec and BGP configuration details from the XML.

### Part 2: Local Environment Setup

1. Navigate to the local setup directory:

```bash
cd local
```

2. Update configuration files with your VPN details:
   - Edit `ipsec.secrets` with the pre-shared key
   - Update `ipsec.conf` with AWS VPN endpoints
   - Modify `frr.conf` with BGP peer details

3. Start the local environment:

```bash
docker-compose up -d
```

## Testing Connectivity

1. Verify the IPsec tunnel is established:

```bash
docker exec -it vpn-gw ipsec status
```

2. Check BGP session status:

```bash
docker exec -it frr-router vtysh -c "show ip bgp summary"
```

3. Test connectivity from local network to AWS:

```bash
docker exec -it local-host ping <aws-private-ip>
```

## Exercises

1. **BGP Route Propagation**
   - Add additional routes in the local environment
   - Check route propagation to AWS

2. **Path Selection**
   - Add a second VPN connection
   - Test failover scenarios

3. **Route Filtering**
   - Configure prefix lists on the FRR router
   - Control which routes are advertised to AWS

4. **Route Aggregation**
   - Configure route summarization
   - Observe reduced route table sizes

## Cleanup

1. Stop the local environment:

```bash
docker-compose down
```

2. Destroy AWS resources:

```bash
cd aws
terraform destroy
``` 