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

# RUN go get github.com/kelseyhightower/confd
# WORKDIR /go/src/github.com/kelseyhightower/confd
# RUN ln -s $PWD /confd
# RUN git checkout $CONFD_VERSION
# RUN make

RUN mkdir -p /confd/bin
RUN curl -L https://github.com/kelseyhightower/confd/releases/download/${CONFD_VERSION}/confd-${CONFD_VERSION#v}-linux-amd64 -o /confd/bin/confd
RUN chmod +x /confd/bin/confd


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
      git \
      iperf3 \
      iproute \
      iptables \
      keyutils \
      less \
      net-tools \
      nmap-ncat \
      openssh-server \
      python3 \
      python3-pip \
      strace \
      unzip \
    && yum clean all \
    && rm -rf /var/cache/yum /var/tmp/* /tmp/*

RUN pip3 install \
      awscli \
    && rm -rf /root/.cache/pip

COPY --from=confd-builder   /confd/bin/confd /usr/local/bin/confd
COPY --from=su-exec-builder /su-exec/su-exec /usr/local/bin/su-exec
COPY --from=jq-exec-builder /jq/jq           /usr/local/bin/jq

RUN VER=$(curl -L https://dl.k8s.io/release/stable.txt) && \
    curl -L https://dl.k8s.io/release/$VER/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod 755 /usr/local/bin/kubectl

RUN TMP=$(mktemp -d) && \
    curl -L https://aka.ms/downloadazcopy-v10-linux | tar xvz -C $TMP --strip-components 1 && \
    cp $TMP/azcopy /usr/local/bin/azcopy && \
    chmod 755 /usr/local/bin/azcopy && \
    rm -rf $TMP

ARG TINI_VERSION=v0.19.0
RUN curl -L https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini -o /tini && \
    chmod +x /tini

ARG AUTHORIZED_KEYS_URL=https://raw.githubusercontent.com/stawii/public-keys/master/id_rsa.pub
RUN mkdir -vp /root/.ssh && \
    chmod 700 /root/.ssh && \
    curl -L ${AUTHORIZED_KEYS_URL} >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys

ENV SIMPLE_WEBROOT /srv/webroot
RUN mkdir -vp $SIMPLE_WEBROOT

COPY *-entrypoint.sh /
