# Lab 2: Containerlab BGP Topology

This lab uses Containerlab to create a more sophisticated BGP network topology with route reflectors, communities, and multiple autonomous systems.

## Topology

```
   +-------------------+       +-------------------+
   |      AS 65000     |       |      AS 65000     |
   |    RR1 (rr1)      |       |    RR2 (rr2)      |
   +--------+----------+       +---------+---------+
            |                            |
            |                            |
            |                            |
   +--------+----------------------------+---------+
   |                   AS 65000                    |
   |                BB1 (bb1)                      |
   +--------+----------------------------+---------+
            |                            |
            |                            |
 +----------+-----------+     +----------+-----------+
 |      AS 65001        |     |      AS 65002        |
 |   Client1 (client1)  |     |   Client2 (client2)  |
 +----------------------+     +----------------------+
```

This lab demonstrates:
- BGP Route Reflectors (RR1 and RR2)
- IBGP and EBGP sessions
- Route filtering with communities
- Path manipulation

## Prerequisites

- Containerlab installed (https://containerlab.dev/install/)
- Docker installed
- Basic understanding of BGP

## Files

- `topology.yml`: Containerlab topology definition
- `configs/`: Directory with FRR configurations for each node
- `run.sh`: Helper script to deploy the lab
- `cleanup.sh`: Script to tear down the lab

## Setup Instructions

1. Deploy the lab:

```bash
./run.sh
```

This will:
- Create the containerlab topology
- Configure each router with the appropriate BGP settings
- Set up peering relationships

2. Verify the lab is running:

```bash
containerlab inspect
```

3. Access a router's CLI:

```bash
docker exec -it clab-bgp-rr1 vtysh
```

## Exercises

1. **Route Reflection Verification**
   - Check client routes being reflected between clients
   - Verify RR cluster configuration

2. **Community-Based Filtering**
   - Examine how routes are filtered based on communities
   - Add communities to routes and observe propagation behavior

3. **Route Manipulation**
   - Configure and test AS path prepending
   - Implement local preference to influence path selection

4. **High Availability Testing**
   - Simulate failure of one route reflector
   - Observe convergence behavior

5. **Advanced BGP Policy**
   - Configure conditional route advertisement
   - Implement route aggregation

## Cleanup

When finished with the lab, run:

```bash
./cleanup.sh
```

This will remove all containers and networks created by Containerlab. 