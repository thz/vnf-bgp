#!/bin/bash -e

here=`dirname $0`
. $here/common.sh

name=alice
image=test

localas=65010
localip=192.0.2.10
peer=192.0.2.20
neighbors=65020@$peer

run_neighbor
