#!/bin/bash -e

here=`dirname $0`
. $here/common.sh

name=alice

localip=192.0.2.10
BGP_LOCAL_AS=65010
BGP_ROUTER_ID=$localip
BGP_NEIGHBORS=65020@192.0.2.20

run_neighbor
