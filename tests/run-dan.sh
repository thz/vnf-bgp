#!/bin/bash -e

here=`dirname $0`
. $here/common.sh

name=dan

localip=192.0.2.40
BGP_LOCAL_AS=65040
BGP_ROUTER_ID=$localip
BGP_NEIGHBORS=64999@192.0.2.20
BGP_AUTHPASSWORD=dead000000000000000000000000beef

run_neighbor
