image=vnf-bgp

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
		-e BGP_ROUTER_ID=$BGP_ROUTER_ID \
		-e BGP_LOCAL_AS=$BGP_LOCAL_AS \
		-e BGP_NEIGHBORS=$BGP_NEIGHBORS \
		-e BGP_AUTHPASSWORD="$BGP_AUTHPASSWORD" \
		-e BGP_NEIGHBOR_COUNT="$BGP_NEIGHBOR_COUNT" \
		-e BGP_NEIGHBOR_0_PEERAS="$BGP_NEIGHBOR_0_PEERAS" \
		-e BGP_NEIGHBOR_0_ADDRESS="$BGP_NEIGHBOR_0_ADDRESS" \
		-e BGP_NEIGHBOR_0_AUTHPASSWORD="$BGP_NEIGHBOR_0_AUTHPASSWORD" \
		-e BGP_NEIGHBOR_0_LOCAL_AS="$BGP_NEIGHBOR_0_LOCAL_AS" \
		-e BGP_FIB_MANIPULATION=yes_please \
		$image
}
