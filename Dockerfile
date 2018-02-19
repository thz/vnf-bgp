FROM golang:1.9 as buildstage

ENV GOPATH /go
WORKDIR /go
RUN go get github.com/osrg/gobgp/gobgp
RUN go get github.com/osrg/gobgp/gobgpd

# FROM bitnami/minideb:jessie as runstage
# FROM cumulusnetworks/quagga as runstage
FROM debian:jessie as runstage

COPY --from=buildstage /go/bin/gobgp /usr/bin
COPY --from=buildstage /go/bin/gobgpd /usr/bin

RUN apt-get update -y
RUN apt-get install -y \
	iproute2 \
	iputils-ping \
	ldnsutils \
	socat \
	strace \
	supervisor \
	tcpdump \
	telnet \
	wget \
	vim

# get FRR release
RUN wget https://github.com/FRRouting/frr/releases/download/frr-3.0.3/frr_3.0.3-1_debian8.1_amd64.deb
RUN dpkg -i frr_3.0.3-1_debian8.1_amd64.deb || apt-get install -fy

ADD entry-bgp.sh /usr/local/bin
RUN chmod 0755 /usr/local/bin/entry-bgp.sh

ENTRYPOINT [ "/usr/local/bin/entry-bgp.sh" ]
