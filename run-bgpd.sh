#!/bin/bash -e
#
# scope: testing with local / outside k8s
#
# run bgpd

name=bgpd
image=vnf-bgp

docker stop $name || true
docker rm $name || true

docker run -d --name=$name \
	--net=host \
	-v /opt/local/etc/bgp.yml:/etc/gobgpd.yml:ro \
	$image \
	/usr/bin/gobgpd -f /etc/gobgpd.yml

docker logs -f $name
