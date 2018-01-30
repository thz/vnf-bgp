FROM golang:1.8 as buildstage

ENV GOPATH /go
WORKDIR /go
RUN go get github.com/osrg/gobgp/gobgp
RUN go get github.com/osrg/gobgp/gobgpd

# FROM bitnami/minideb:jessie as runstage
# FROM cumulusnetworks/quagga as runstage
FROM osrg/quagga as runstage

COPY --from=buildstage /go/bin/gobgp /usr/bin
COPY --from=buildstage /go/bin/gobgpd /usr/bin

RUN apt-get update -y && apt-get install -y iproute2 iputils-ping vim tcpdump socat strace ldnsutils

ADD entry-bgp.sh /usr/local/bin
RUN chmod 0755 /usr/local/bin/entry-bgp.sh

ENTRYPOINT [ "/usr/local/bin/entry-bgp.sh" ]
