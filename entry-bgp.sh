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

	if [ -n "$BGP_NEIGHBORS" ]; then
		IFS=,
		for neighbor in $BGP_NEIGHBORS; do
			as=${neighbor%%@*}
			peer=${neighbor##*@}
			cat << EOF
[[neighbors]]
  [neighbors.config]
    neighbor-address = "${peer}"
    peer-as = ${as}

EOF
		done
		unset IFS
	fi

	if [ -n "$BGP_FIB_MANIPULATION" ]; then
		cat << EOF
[zebra]
  [zebra.config]
    enabled = true
    #url = "tcp:127.0.0.1:2601"
    url = "unix:/run/frr/zserv.api"
    version = 4
EOF
		if [ -n "$BGP_FIB_ANNOUNCE" ]; then
			echo '    redistribute-route-type-list = ["connect"]'
		else
			echo '    redistribute-route-type-list = []'
		fi
	fi

	true
}

create_zebra_config() {
	cat << EOF
hostname zebra
no ipv6 forwarding
password zebra
enable password zebra
line vty
log stdout debugging
EOF
	true
}

run_bgpd() {
	echo "Applying defaults..."
	set_defaults
	echo "Validating input..."
	validate_input
	echo "Creating configuration..."
	create_config_part1 > /run/bgpd-config.toml
	printf ">>> bgpd configuration >>>>>>>>>>>>>>>>>\n"
	cat /run/bgpd-config.toml
	printf "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n"

	if [ -n "$BGP_FIB_MANIPULATION" ]; then
		printf ">>> zebra configuration >>>>>>>>>>>>>>>>>\n"
		create_zebra_config |tee /run/zebra.conf
		printf "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n"
		echo "Starting fib manipulator..."
		/usr/lib/frr/zebra --config_file /run/zebra.conf &
		sleep 3
		printf "Done.\n\n"
	fi

	# start a background process to inject routes after gobgpd started
	if [ -n "$BGP_STATIC_ROUTES" ]; then
		echo "Going to inject to rib: $BGP_STATIC_ROUTES"
		nohup env routes="$BGP_STATIC_ROUTES" \
			bash -c "IFS=, ; \
			sleep 1 ; \
			for r in \$routes; do \
				/usr/bin/gobgp global rib add -a ipv4 \$r origin egp ; \
			done" > /dev/null 2>&1 &
	fi

	echo "executing bgp daemon..."
	/usr/bin/gobgpd -f /run/bgpd-config.toml &
	sleep 3
	while true; do
		# Poor man's supervisor.
		if [ -n "$BGP_FIB_MANIPULATION" ]; then
			if ! pidof zebra > /dev/null; then
				echo "Zebra died. Terminating."
				exit 1
			fi
		fi
		if ! pidof gobgpd > /dev/null; then
			echo "Gobgpd died. Terminating."
			exit 1
		fi
		sleep 1
	done
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

[ -n "$ENVFILE" ] && . "$ENVFILE"

if [ -z "$command" ]; then
	run_bgpd
	exit 0
fi
shift # command

if [ "$command" = announce ]; then
	announce "$@"
fi

