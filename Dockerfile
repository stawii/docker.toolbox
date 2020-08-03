##
## ToolBox Dockerfile
##
## Builders have multiple RUNs on purpose - easier to play with.
## Main image is somewhat optimized, but who cares..

ARG CENTOS_BASE=centos:7


##################
## confd builder

FROM golang:1 as confd-builder

ARG CONFD_VERSION=v0.16.0

RUN go get github.com/kelseyhightower/confd
WORKDIR /go/src/github.com/kelseyhightower/confd
RUN ln -s $PWD /confd
RUN git checkout $CONFD_VERSION
RUN make


####################
## su-exec builder

FROM gcc:8 as su-exec-builder

RUN git clone https://github.com/ncopa/su-exec.git
WORKDIR su-exec
RUN make


####################
## jq-exec builder

FROM gcc:8 as jq-exec-builder

RUN git clone https://github.com/stedolan/jq.git
WORKDIR jq
RUN git checkout jq-1.6
RUN git submodule update --init
RUN autoreconf -fi
RUN ./configure --with-oniguruma=builtin
RUN make LDFLAGS=-all-static


###############
## main image

FROM $CENTOS_BASE

RUN curl -L https://download.docker.com/linux/centos/docker-ce.repo \
      -o /etc/yum.repos.d/docker-ce.repo

RUN yum -y install \
      bind-utils \
      docker-ce-cli \
      iperf3 \
      iproute \
      iptables \
      less \
      net-tools \
      nmap-ncat \
      python3 \
      python3-pip \
      strace \
    && yum clean all \
    && rm -rf /var/cache/yum /var/tmp/* /tmp/*

COPY --from=confd-builder   /confd/bin/confd /usr/local/bin/confd
COPY --from=su-exec-builder /su-exec/su-exec /usr/local/bin/su-exec
COPY --from=jq-exec-builder /jq/jq           /usr/local/bin/jq

RUN VER=$(curl -L https://dl.k8s.io/release/stable.txt) && \
    curl -L https://dl.k8s.io/release/$VER/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod 755 /usr/local/bin/kubectl
