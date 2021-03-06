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

# statically inject routes into global rib immediately after startup:
BGP_STATIC_ROUTES=192.0.2.0/28,192.0.2.128/25

# do fib manipulation
BGP_FIB_MANIPULATION=yes

# put routes from FIB into RIB (announce routes found in kernel)
# (only applicable with BGP_FIB_MANIPULATION enabled)
BGP_FIB_ANNOUNCE=yes

# maximum acceptable as-path length
BGP_MAX_PATH=1
