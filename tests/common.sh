create_net() {
	docker network create --subnet=192.0.2.0/24 examplenet
}
run_neighbor() {
	docker run --rm -ti \
		--name $name \
		--network examplenet \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_ADMIN \
		--cap-add=SETPCAP \
		--cap-add=NET_RAW \
		--ip=$localip \
		-e BGP_ROUTER_ID=$peer \
		-e BGP_LOCAL_AS=$localas \
		-e BGP_NEIGHBORS=$neighbors \
		-e BGP_FIB_MANIPULATION=yes_please \
		$image
}
