# BGP with FRRouting in Docker Lab

This lab demonstrates a basic BGP setup using FRRouting (FRR) in Docker containers. It creates a hub-and-spoke topology with multiple autonomous systems to simulate a real-world BGP environment.

## Topology

```
                      +-------------+
                      |    AS 65000  |
                      |  Router-1   |
                      +------+------+
                             |
                             |
         +-------------------+-------------------+
         |                   |                   |
 +-------+-------+   +-------+-------+   +-------+-------+
 |   AS 65001    |   |   AS 65002    |   |   AS 65003    |
 |   Router-2    |   |   Router-3    |   |   Router-4    |
 +---------------+   +---------------+   +---------------+
```

The lab consists of four routers in a hub-and-spoke topology:
- **Router1 (AS65000)**: The central hub connected to all other routers
- **Router2 (AS65001)**: Spoke router connected only to Router1
- **Router3 (AS65002)**: Spoke router connected only to Router1
- **Router4 (AS65003)**: Spoke router connected only to Router1

Each router is in its own Autonomous System (AS), simulating connections between different networks.

## Prerequisites

- Docker and Docker Compose installed
- Basic understanding of BGP and networking concepts

## Files

- `docker-compose.yml`: Defines the containers and networks
- `frr-configs/`: Directory containing FRR configuration files for each router
- `run.sh`: Helper script to start the lab
- `cleanup.sh`: Helper script to clean up resources

## Setup Instructions

1. Create and start the lab environment:

```bash
./run.sh
```

This script will:
- Clean up any existing lab resources
- Create the necessary FRR configuration files
- Build and start the Docker containers

2. Verify BGP peerings:

```bash
docker exec -it router1 vtysh -c "show ip bgp summary"
```

3. Check routes:

```bash
docker exec -it router1 vtysh -c "show ip route bgp"
```

4. Access the FRR CLI on any router:

```bash
docker exec -it router1 vtysh
```

Replace `router1` with `router2`, `router3`, or `router4` to access other routers.

## Useful Commands

- Show BGP summary: `docker exec -it router1 vtysh -c "show ip bgp summary"`
- Show BGP routes: `docker exec -it router1 vtysh -c "show ip bgp"`
- Show routing table: `docker exec -it router1 vtysh -c "show ip route bgp"`

## Understanding BGP in This Lab

### BGP as a Route Synchronization Protocol

BGP's primary function is to synchronize routing tables between autonomous systems. Here's how it works:

1. **Exchange of Reachability Information**: BGP routers exchange information about which networks (prefixes) they can reach and how.

2. **Path Vector Protocol**: BGP doesn't just share routes - it shares the entire path to reach a destination (the AS path), which helps prevent routing loops.

3. **Policy-Based Updates**: Unlike simpler protocols, BGP allows extensive filtering and modification of routes based on policies (route maps in our lab).

4. **Incremental Updates**: After the initial full table exchange, BGP only sends updates when routes change, making it efficient for large networks.

### The Synchronization Process

When our lab routers run BGP:

1. **Initial Exchange**: When BGP sessions first establish, routers exchange their full routing tables.

2. **Routing Information Base (RIB)**: Each router maintains a BGP table of all learned routes.

3. **Best Path Selection**: BGP applies a complex path selection algorithm to choose the best route for each destination.

4. **Route Installation**: Only the best routes get installed into the actual IP routing table used for forwarding packets.

5. **Ongoing Updates**: As network conditions change, BGP sends incremental updates to keep all routers' tables synchronized.

### BGP Path Selection Process

BGP may learn multiple paths to the same destination, and it uses a well-defined path selection algorithm to choose the "best" path. In our lab, you can experiment with this process, which is crucial for understanding how BGP makes routing decisions.

The BGP path selection algorithm follows these steps in order, stopping when a decision is made:

1. **Highest Weight** (Cisco-specific, not used in FRR)
2. **Highest Local Preference** (Default is 100)
3. **Locally Originated Routes** (Prefer routes originated by this router)
4. **Shortest AS Path** (Prefer routes with fewer AS hops)
5. **Lowest Origin Type** (IGP < EGP < Incomplete)
6. **Lowest MED** (Metric to a neighboring AS)
7. **eBGP over iBGP** (Prefer external routes over internal routes)
8. **Lowest IGP metric to BGP next hop**
9. **Router ID** (Prefer the path from the neighbor with the lowest router ID)
10. **Lowest Neighbor Address** (Tie-breaker)

In our lab, you can observe this algorithm in action with commands like:

```bash
# Show all BGP paths for a specific prefix
docker exec -it router1 vtysh -c "show ip bgp 2.2.2.2/32"

# Show the currently selected best path
docker exec -it router1 vtysh -c "show ip bgp 2.2.2.2/32 bestpath"

# Show details about how BGP made its path selection
docker exec -it router1 vtysh -c "show ip bgp 2.2.2.2/32 detail"
```

You can influence path selection in several ways:

1. **AS Path Prepending**: Making a path look longer by repeating AS numbers
   ```
   neighbor 172.30.0.10 route-map PREPEND out
   route-map PREPEND permit 10
     set as-path prepend 65001 65001
   ```

2. **Local Preference**: Setting higher preference for certain paths
   ```
   neighbor 172.30.0.10 route-map SETLOCALPREF in
   route-map SETLOCALPREF permit 10
     set local-preference 200
   ```

3. **MED Manipulation**: Setting the Multi-Exit Discriminator
   ```
   neighbor 172.30.0.10 route-map SETMED out
   route-map SETMED permit 10
     set metric 50
   ```

Try implementing these methods in the lab exercises to see how they affect BGP's route selection.

### Router Loopbacks and Their Importance

Router loopback interfaces are virtual interfaces configured with IP addresses, and they play a crucial role in BGP:

#### Router Loopback vs. 127.0.0.1

- **127.0.0.1** is the standard localhost loopback address that exists on virtually all TCP/IP-capable devices. It always refers to "this device" and is not routable across networks.

- **Router loopback interfaces** (like 1.1.1.1, 2.2.2.2 in our lab) are virtual interfaces configured on routers with globally routable IP addresses. These are completely different from the 127.0.0.1 address.

#### Why Routers Advertise Loopback Addresses in BGP

1. **Stability**: Loopback interfaces are virtual and never go down unless the entire router fails. This provides a stable identifier for the router.

2. **BGP Router ID**: The loopback address is often used as the BGP Router ID, which uniquely identifies the router in BGP exchanges.

3. **iBGP Peering**: In larger networks, routers use loopback addresses for iBGP sessions because they're more stable than physical interface IPs that might go down.

4. **Management and Monitoring**: Network operators need stable addresses to reach routers for monitoring, troubleshooting, and management.

5. **Route Reachability Testing**: Loopback addresses serve as "ping targets" to verify connectivity through the network.

In our lab, each router advertises its unique loopback address (1.1.1.1, 2.2.2.2, etc.) into BGP. When these routes are learned by other routers, it establishes end-to-end reachability.

### BGP Configuration Components

#### 1. Router Identity and AS Numbers

Each router has:
- A BGP router ID (its loopback IP)
- An AS number
- Peering relationships with neighbors

For example, Router1's configuration shows:
```
router bgp 65000
 bgp router-id 1.1.1.1
 bgp log-neighbor-changes
```

#### 2. BGP Neighbor Relationships

BGP sessions are established between neighbors. Router1 connects to all other routers:
```
 neighbor 172.30.0.2 remote-as 65001  # Connection to Router2
 neighbor 172.30.0.3 remote-as 65002  # Connection to Router3
 neighbor 172.30.0.4 remote-as 65003  # Connection to Router4
```

#### 3. Address Families and Route Advertisement

The `address-family ipv4 unicast` section specifies which routes are advertised:
```
 address-family ipv4 unicast
  redistribute connected           # Share all connected routes
  network 1.1.1.1/32               # Advertise specific networks
  neighbor 172.30.0.2 activate     # Enable BGP for this neighbor
```

#### 4. Route Policies (Route Maps)

Route maps control which routes are accepted or advertised:
```
route-map ACCEPT permit 10         # Simple policy to permit all routes
```

### Route Filtering with BGP

BGP provides extensive capabilities for filtering routes based on various criteria. In this lab, you can experiment with route filtering using:

1. **Prefix Lists**: Filter routes based on IP prefixes and prefix lengths
   ```
   ip prefix-list FILTER-LIST seq 5 permit 1.1.1.1/32
   router bgp 65000
     neighbor 172.30.0.2 prefix-list FILTER-LIST out
   ```

2. **AS Path Access Lists**: Filter routes based on AS path attributes
   ```
   ip as-path access-list 1 permit ^65001$
   router bgp 65000
     neighbor 172.30.0.2 filter-list 1 in
   ```

3. **Route Maps**: More complex filtering with multiple match and set statements
   ```
   route-map FILTER-MAP deny 10
     match ip address prefix-list FILTER-LIST
   route-map FILTER-MAP permit 20
   ```

These filtering mechanisms allow BGP to implement complex routing policies, one of its key strengths as an inter-domain routing protocol.

### BGP Process Flow

1. **Startup**: Each router starts FRR services with the configured BGP settings
   
2. **BGP Session Establishment**: Routers establish TCP sessions (port 179) with neighbors and exchange OPEN messages

3. **Route Exchange**:
   - Each router advertises its loopback address (1.1.1.1/32, 2.2.2.2/32, etc.)
   - Routes pass through route map policies (ACCEPT in our case)
   - Routes are stored in the BGP table (RIB - Routing Information Base)

4. **Route Selection**: BGP selects the best routes based on its path selection algorithm

5. **Route Installation**: Best routes are installed into the IP routing table

This can be seen in the example outputs:

```
# BGP summary showing established sessions and received prefixes
BGP table version is 5
RIB entries 9, using 1152 bytes of memory
Peers 3, using 50 KiB of memory

Neighbor        V     AS   MsgRcvd   MsgSent  State/PfxRcd
172.30.0.2      4   65001      8        9           2
172.30.0.3      4   65002      8        9           2
172.30.0.4      4   65003      8        9           2
```

```
# Routes learned via BGP installed in routing table
B>* 2.2.2.2/32 [20/0] via 172.30.0.2, eth0, weight 1, 00:00:49
B>* 3.3.3.3/32 [20/0] via 172.30.0.3, eth0, weight 1, 00:00:49
B>* 4.4.4.4/32 [20/0] via 172.30.0.4, eth0, weight 1, 00:00:49
```

## Key BGP Features Demonstrated

1. **External BGP (eBGP)**: All connections are between different AS numbers
2. **Route Redistribution**: Connected routes are redistributed into BGP
3. **BGP Attributes**: Administrative distance [20/0] and next-hop information
4. **Policy Control**: Route maps determine which routes are accepted/advertised

## How FRR Implements BGP

FRR (FRRouting) is not just an implementation of BGP - it's a complete routing software suite that implements multiple routing protocols, including BGP, OSPF, IS-IS, RIP, and others.

FRR consists of several daemons (background processes), each handling a specific routing protocol:
- `bgpd` - the daemon that implements BGP
- `ospfd` - implements OSPFv2
- `zebra` - core daemon that interfaces with the kernel routing table
- And several others for different protocols

In our lab, we primarily use FRR's implementation of BGP (the `bgpd` daemon) to establish sessions between the routers and exchange routes. But FRR itself is much more than just BGP - it's a comprehensive routing platform that evolved from the Quagga project and before that, from GNU Zebra.

The configuration files control how these daemons operate:
- **frr.conf**: Main configuration file with routing protocols
- **daemons**: Controls which routing daemons are enabled
- **vtysh.conf**: Configuration for the command-line interface

## Exercises

1. **Basic Connectivity Test**
   - Verify all BGP sessions are established
   - Ping between router loopbacks

2. **Route Filtering**
   - Modify Router-1 to filter certain prefixes using prefix-lists
   - Observe changes in routing tables before and after applying filters
   - Try allowing only even-numbered loopbacks (2.2.2.2, 4.4.4.4) to be advertised

3. **Path Manipulation**
   - Configure AS path prepending on Router-2 to make its routes less preferred
   - Set higher local preference on Router-3's routes
   - Compare how path selection works before and after these changes

4. **Failover Testing**
   - Stop router3 and observe how the network reconverges
   - Check the BGP tables on all routers to see how routes disappear
   - Start router3 and monitor route recovery

5. **Route Reflector**
   - Reconfigure Router-1 as a route reflector
   - Change spoke routers to not peer with each other
   - Observe how routes are shared via the route reflector

## Cleanup

When finished with the lab, run:

```bash
./cleanup.sh
```

Or manually clean up with:

```bash
docker compose down --volumes --remove-orphans
docker network prune -f
```

## Learning Objectives

After completing this lab, you should understand:
- Basic BGP configuration with FRR
- How BGP establishes peering relationships
- How routes are exchanged between autonomous systems
- BGP path selection algorithm and how to influence routing decisions
- How to implement route filtering and policy control
- Network reconvergence during failures
- How to troubleshoot BGP routing issues 

## Relevance to AWS Advanced Networking Specialty Certification

This BGP lab is highly relevant to the AWS Advanced Networking Specialty certification, which tests your understanding of complex networking concepts including BGP. Here's how this lab relates to the exam:

### BGP in AWS Services

Several AWS services utilize BGP or concepts related to it:

1. **AWS Direct Connect**: Uses BGP to exchange routes between your on-premises network and AWS. You'll need to understand BGP attributes, path selection, and route manipulation.

2. **AWS Transit Gateway**: When connecting to on-premises networks via Direct Connect or VPN, Transit Gateway uses BGP for dynamic routing.

3. **Site-to-Site VPN**: AWS supports dynamic routing using BGP for VPN connections.

4. **Route Advertisement**: Understanding how prefixes are advertised and propagated is crucial when working with complex AWS hybrid architectures.

### Exam Topics Related to This Lab

Based on the exam blueprint, you can expect questions on:

1. **BGP Path Selection**: Understanding why a specific route was selected over another when using Direct Connect or VPN connections.

2. **AS Path Prepending**: How to make certain routes less preferred in hybrid AWS environments.

3. **Route Filters and Policies**: How to control which routes are advertised to or accepted from AWS.

4. **High Availability Design**: Using BGP to design resilient connections between on-premises networks and AWS.

5. **Troubleshooting Scenarios**: Diagnosing and resolving routing issues in hybrid networks.

### Example Scenario Questions

The exam often includes scenario-based questions like:

- "A company has established dual Direct Connect connections to AWS. Traffic is consistently using only one connection. What BGP configuration would balance traffic across both connections?"

- "Your organization has a primary Direct Connect connection and a backup Site-to-Site VPN. How would you configure BGP to ensure the Direct Connect path is always preferred when available?"

- "When connecting multiple VPCs through a Transit Gateway to an on-premises network via Direct Connect, what route advertisement approach would minimize the number of prefixes exchanged?"

The hands-on experience gained in this lab will help you understand the underlying concepts that appear in these types of questions, even though the AWS services add their own specific implementation details. 