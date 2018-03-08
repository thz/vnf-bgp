#!/bin/bash -e

here=`dirname $0`
. $here/common.sh

name=chuck

localip=192.0.2.30
BGP_LOCAL_AS=65030
BGP_ROUTER_ID=$localip
BGP_NEIGHBORS=65020@192.0.2.20

run_neighbor
