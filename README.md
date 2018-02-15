# BGP peer

This container image provides a BGP peer.

The current implementation uses gobgpd but the idea is to
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

### Configuration

Configuration is done by environment variables. See below for available options.
Alternatively it is (will be) also possible to point $ENVFILE to an environment file which is sourced before startup.

```sh
# source specified file before startup.
ENVFILE=/tmp/generated-config.env

# the identification (and peer address) of ourself
BGP_ROUTER_ID=192.0.2.1

# statically inject routes into global rib immediately after startup:
BGP_STATIC_ROUTES=192.0.2.0/28,192.0.2.128/25

# do fib manipulation
BGP_FIB_MANIPULATION=yes
