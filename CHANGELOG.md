## 1.1.0 / 2018-03-06

* Added BGP_AUTHPASSWORD config for bgp authentication
* Improve teardown time (SIGTERM handler).

## 1.0.3 / 2018-02-20

* Added a delay after starting BGPd to prevent watchdog barking before real startup.

## 1.0.2 / 2018-02-19

* Terminate when FIB manipulator (zebra) or BGPd (gobgpd) terminates.

## 1.0.1 / 2018-02-19

* Use golang:1.9 as base for gobgp

## 1.0.0 / 2018-02-19

This is the initial release.
BGP peers can be set up with a configured list of neighbors,
a configured list of (static) routes for the RIB/announcements,
and some more configurable options.
FIB manipulation based on RIB can be enabled or disabled.
Putting connected routes to the RIB is optional.

