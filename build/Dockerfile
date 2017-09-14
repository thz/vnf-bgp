FROM golang:1.8 as buildstage

ENV GOPATH /go
WORKDIR /go
RUN go get github.com/osrg/gobgp/gobgp
RUN go get github.com/osrg/gobgp/gobgpd

FROM bitnami/minideb:jessie as runstage
COPY --from=buildstage /go/bin/gobgp /usr/bin
COPY --from=buildstage /go/bin/gobgpd /usr/bin
