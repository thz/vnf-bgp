# BGP peer

This container image provides a BGP peer.

The current implementation uses gobgpd but the idea is to
have the implementation details abstracted away.

### Run this container

To run the container execute the following section:

```
# docker run -e BGP_ROUTER_ID openvnf/vnf-bgp
```

### Configuration

Configuration is done by environment variables. See below for available options.
Alternatively it is (will be) also possible to point $ENVFILE to an environment file which is sourced before startup.

```sh
# source specified file before startup.
ENVFILE=

BGP_ROUTER_ID=192.0.2.1
