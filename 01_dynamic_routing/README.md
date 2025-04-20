# AWS Advanced Networking - Dynamic Routing Labs

This directory contains practical labs for learning and practicing dynamic routing concepts with a focus on AWS networking. These labs are designed to help prepare for the AWS Advanced Networking Specialty certification.

## Introduction to BGP

Border Gateway Protocol (BGP) is the routing protocol that powers the internet, enabling networks to exchange routing information across autonomous systems (AS). Key BGP concepts include:

- **Autonomous System (AS)**: A collection of networks under a single administrative domain, identified by a unique AS number (ASN).
- **EBGP vs IBGP**: External BGP (EBGP) connects different autonomous systems, while Internal BGP (IBGP) connects routers within the same AS.
- **BGP Path Selection**: BGP uses a multi-step algorithm to select the best path, considering attributes like AS path length, origin, MED, and local preference.
- **Route Advertisement**: Networks announce (advertise) reachable prefixes to their BGP peers.
- **Route Filtering**: Using prefix lists, route maps, and communities to control which routes are advertised or accepted.
- **BGP Communities**: Tags that can be attached to routes to influence routing decisions across network boundaries.

In AWS, BGP is used for:
- Site-to-Site VPN connections with dynamic routing
- Direct Connect connections
- Transit Gateway route exchange
- Third-party virtual appliances for advanced routing

## About FRRouting (FRR)

FRRouting (FRR) is an open-source routing protocol suite that implements various routing protocols including BGP, OSPF, IS-IS, and RIP. FRR features:

- Modern, modular architecture derived from Quagga
- Support for multiple routing daemons (bgpd, ospfd, etc.)
- Industry-standard CLI similar to Cisco IOS
- Wide protocol support for IPv4 and IPv6
- Active development and community support

FRR is an excellent choice for lab environments because:
- It's lightweight and can run in containers
- It includes comprehensive BGP functionality
- It's free and open-source
- It's similar to enterprise routing platforms

In these labs, we'll use FRR to simulate BGP routing in various scenarios, from simple container-based topologies to complex AWS networking environments.

## Lab Options

### Lab 1: FRRouting in Docker

**Objective:** Set up a BGP network using FRRouting in Docker containers.

**Components:**
- 4 FRR containers representing different autonomous systems
- Custom Docker networks for L2 connectivity
- BGP peering configuration between routers
- Route advertisement and filtering

**Learning Goals:**
- Configure BGP peering sessions
- Understand BGP path selection
- Implement route filtering
- Simulate network failures and observe reconvergence

### Lab 2: Containerlab BGP Topology

**Objective:** Use Containerlab to create a more sophisticated BGP network topology.

**Components:**
- Multiple FRR/VyOS routers with different roles
- Route reflectors configuration
- AS path manipulation
- Communities and route policies

**Learning Goals:**
- Work with route reflectors
- Understand BGP communities
- Implement complex routing policies
- Monitor BGP session states

### Lab 3: AWS Transit Gateway BGP Lab

**Objective:** Configure BGP between VPCs using AWS Transit Gateway and EC2 instances.

**Components:**
- 2 VPCs in different regions
- Transit Gateway with multiple route tables
- EC2 instances running FRR for BGP
- Site-to-Site VPN connections with BGP

**Learning Goals:**
- Configure BGP over VPN connections
- Understand AWS Transit Gateway routing
- Implement route propagation controls
- Test failover scenarios

### Lab 4: Hybrid BGP Connectivity (On-premises to AWS)

**Objective:** Connect a local BGP network to AWS using VPN with BGP routing.

**Components:**
- Local FRR network (containerized)
- AWS VPC with Virtual Private Gateway
- IPsec VPN with BGP
- Route advertisement between on-premises and AWS

**Learning Goals:**
- Configure BGP over VPN connections
- Understand route propagation between on-premises and AWS
- Implement prefix filtering and route manipulation
- Test hybrid connectivity scenarios

## Prerequisites

- Basic understanding of BGP concepts
- Docker and Docker Compose installed (for local labs)
- AWS account (for AWS-based labs)
- Terraform (optional, for infrastructure as code deployment)
- Containerlab (optional, for advanced network topologies)

## Getting Started

Each lab has its own subdirectory with specific instructions and files:

1. `/lab1-frr-docker` - Docker Compose-based FRR BGP lab
2. `/lab2-containerlab` - Containerlab topology for advanced BGP scenarios
3. `/lab3-aws-tgw` - Terraform files to deploy the AWS Transit Gateway lab
4. `/lab4-hybrid` - Instructions and configurations for hybrid connectivity

Follow the README in each lab directory for detailed setup instructions. 