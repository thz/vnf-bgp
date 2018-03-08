# BGP peer

This container image provides a BGP peer.

The current implementation uses gobgpd for bgp protocol
and FRR/zebra for FIB manipulation. But the idea is to
have the implementation details abstracted away.

FIB manipulation currently requires some capability:
	NET_ADMIN, SYS_ADMIN, SETPCAP, NET_RAW

### Run this container

Example for running this container:

```
# docker run \
	-e BGP_ROUTER_ID=192.0.2.1 \
	-e BGP_FIB_MANIPULATION=yes \
	openvnf/vnf-bgp
```

There is also a tests/ subfolder which has some scripts 
prepared for easy playground setup. Meet Alice and Bob
there. They are neighbors and live in docker containers.

### Configuration

Configuration is done by environment variables. See below for available options.
Alternatively it is (will be) also possible to point $ENVFILE to an environment file which is sourced before startup.

```sh
# source specified file before startup.
ENVFILE=/tmp/generated-config.env

# the local AS:
BGP_LOCAL_AS=65000

# the identification (and peer address) of ourself
BGP_ROUTER_ID=192.0.2.1

# The simplest way of specifying neighbors
# (comma separated list of AS/ip pairs):
BGP_NEIGHBORS=65010@192.0.2.10,65020@192.0.2.20

# The more sophisticated way of specifying neighbors
# this allows more neighbor specific options. Counting
# starts at zero.
# (These neighbors will be added in addition to $BGP_NEIGHBORS)
BGP_NEIGHBOR_COUNT=3
BGP_NEIGHBOR_0_PEERAS=65030
BGP_NEIGHBOR_0_ADDRESS=192.0.2.30
BGP_NEIGHBOR_0_AUTHPASSWORD=secret
BGP_NEIGHBOR_0_LOCAL_AS=64999
BGP_NEIGHBOR_0_MAX_IMPORT_PATH_LENGTH=1 (not yet implemented)
BGP_NEIGHBOR_1_...
BGP_NEIGHBOR_2_...

# statically inject routes into global rib immediately after startup:
BGP_STATIC_ROUTES=192.0.2.0/28,192.0.2.128/25

# do fib manipulation
BGP_FIB_MANIPULATION=yes

# put routes from FIB into RIB (announce routes found in kernel)
# (only applicable with BGP_FIB_MANIPULATION enabled)
BGP_FIB_ANNOUNCE=yes

# maximum acceptable as-path length for imports
# This option is deprecated. Use per neighbor config
# instead (as soon as it is implemented).
BGP_MAX_PATH=1

# BGP authentication password. Shared over all neighbors
# (Currently only one shared password for all neighbors.)
BGP_AUTHPASSWORD=secret
```

### Caveats and Pitfalls

Routes pushed towards FIB maniupulation are considered "inactive" unless the next hop is considered directly connected by the FIB manipulator (currently being Frr/Zebra). Routes in the kernel table are not enough for being "directly connected". When you have your next hop connected via a vti interface without having an IP address in that network you can "connect" your neighbor with the peer specification of `ip addr add`:

```
ip addr add YOUR_IP/32 peer YOUR_PEER dev vti42
```

This will make YOUR_PEER appear as directly connected and allow FIB propagation to the kernel table(s).
