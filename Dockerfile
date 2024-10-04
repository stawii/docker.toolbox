##
## ToolBox Dockerfile
##
## Builders have multiple RUNs on purpose - easier to play with.
## Main image is somewhat optimized, but who cares..

## main image

FROM debian:12

RUN apt update \
    && apt install -y \
    bind9-dnsutils \
    colordiff \
    coreutils \
    curl \
    direnv \
    fdupes \
    file \
    fswatch \
    git \
    gnupg \
    htop \
    iperf \
    iperf3 \
    iproute2 \
    iptables \
    iputils-ping \
    jq \
    keyutils \
    less \
    make \
    man \
    mc \
    moreutils \
    mtr-tiny \
    ncdu \
    net-tools \
    netcat-openbsd \
    openssh-client \
    openssh-server \
    openssl \
    procps \
    pv \
    pwgen \
    python3 python3-venv \
    redis-tools \
    socat \
    squashfs-tools \
    strace \
    tini \
    tmux \
    tree \
    tty-clock \
    util-linux \
    vim \
    wget \
    yq \
    zip unzip \
    && pwd

# TODO: docker-ce-cli

RUN git clone https://github.com/asdf-vm/asdf.git /opt/asdf
RUN /opt/asdf/bin/asdf update
COPY asdf-bash.sh /etc/profile.d/asdf.sh

ENV SIMPLE_WEBROOT /srv/webroot
RUN mkdir -vp $SIMPLE_WEBROOT

COPY *-entrypoint.sh /
