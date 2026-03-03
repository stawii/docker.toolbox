##
## ToolBox Dockerfile
##
## Builders have multiple RUNs on purpose - easier to play with.
## Main image is somewhat optimized, but who cares..

## main image

FROM debian:13

RUN apt update && apt install --yes --no-install-recommends \
    bash-completion \
    bind9-dnsutils \
    ca-certificates \
    colordiff \
    coreutils \
    curl \
    direnv \
    docker-cli \
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
    locales \
    lsof \
    make \
    man \
    mc \
    moreutils \
    mtr-tiny \
    ncdu \
    net-tools \
    netcat-openbsd \
    nftables \
    openssh-client \
    openssh-server \
    openssl \
    patch \
    procps \
    psmisc \
    pv \
    pwgen \
    python3 python3-venv \
    redis-tools \
    socat \
    sqlite3 \
    squashfs-tools \
    strace \
    tini \
    tmux \
    tree \
    tty-clock \
    util-linux \
    vim \
    wget \
    xxd \
    yq \
    zip unzip \
    && pwd

ARG ASDF_VERSION=0.18.0
RUN curl -L "https://github.com/asdf-vm/asdf/releases/download/v${ASDF_VERSION}/asdf-v${ASDF_VERSION}-linux-amd64.tar.gz" \
    | tar xzv -C /usr/bin/ \
    && asdf version

ENV SIMPLE_WEBROOT=/srv/webroot
RUN mkdir -vp $SIMPLE_WEBROOT

COPY *-entrypoint.sh /
