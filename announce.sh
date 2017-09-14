#!/bin/bash -e
#
# scope: testing with local / outside k8s
#
# announce a prefix

prefix="$1"
test -n "$prefix"

name=bgp-announce-$$
image=vnf-bgp

docker run --rm -ti --name=$name --net=host $image \
	gobgp global rib add -a ipv4 $prefix origin egp
sleep 1
docker run --rm -ti --name=$name --net=host $image \
	gobgp global rib
