#!/bin/bash -e

here=`dirname $0`
. $here/common.sh

name=bob
image=test

localas=65020
localip=192.0.2.20
peer=192.0.2.10
neighbors=65010@$peer

run_neighbor
