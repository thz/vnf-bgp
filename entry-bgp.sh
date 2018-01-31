#!/bin/bash

set -e

die() {
	echo "$@"
	exit 1
}

set_defaults() {
	export BGP_LOCAL_AS=${BGP_LOCAL_AS:-65000}
}

validate_input() {
	[ -z "$BGP_LOCAL_AS" ] && die "BGP_LOCAL_AS not set."
	[ -z "$BGP_ROUTER_ID" ] && die "BGP_ROUTER_ID not set."
	true
}

create_config_part1() {
	cat << EOF
[global.config]
	as = $BGP_LOCAL_AS
	router-id = "$BGP_ROUTER_ID"
EOF

	if [ -n "$BGP_MAX_PATH" ]; then
	cat << EOF
[global.apply-policy.config]
	default-import-policy = "reject-route"
	import-policy-list = ["policy_max_path"]
[[policy-definitions]]
	name = "policy_max_path"
	[[policy-definitions.statements]]
		name = "statement1"
		[policy-definitions.statements.conditions.bgp-conditions.as-path-length]
		operator = "le"
		value = $BGP_MAX_PATH
	[policy-definitions.statements.actions]
		route-disposition = "accept-route"
EOF
	fi

	if [ -n "$BGP_NEIGHBOR_COUNT" ]; then
		echo "[[neighbors]]"
		idx=0
		while [ "$BGP_NEIGHBOR_COUNT" -gt $idx ]; do
			var_neighbor_as="BGP_0_NEIGHBOR_${idx}_AS"
			var_neighbor_peer="BGP_0_NEIGHBOR_${idx}_PEER"
			cat << EOF
  [neighbors.config]
    neighbor-address = "${!var_neighbor_peer}"
    peer-as = ${!var_neighbor_as}

EOF
			idx=$((idx+1))
		done
	fi

	true
}

run_bgpd() {
	echo "applying defaults..."
	set_defaults
	echo "validating input..."
	validate_input
	echo "creating configuration..."
	create_config_part1 > /run/bgpd-config.toml
	echo "config >>>>"
	cat /run/bgpd-config.toml
	echo "config <<<<"
	echo "executing bgp daemon..."
	exec /usr/bin/gobgpd -f /run/bgpd-config.toml
}

announce() {
	prefix="$1" ; shift
	if [ -z "$prefix" ]; then
		echo "announce requires a prefix provided on the command line."
		return
	fi
	/usr/bin/gobgp global rib add -a ipv4 "$prefix" origin egp
	sleep 1
	/usr/bin/gobgp global rib
	echo "announce done."
}

command="$1"

if [ -z "$command" ]; then
	run_bgpd
	exit 0
fi
shift # command

if [ "$command" = announce ]; then
	announce "$@"
fi

