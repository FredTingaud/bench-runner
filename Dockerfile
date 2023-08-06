FROM ubuntu:20.04

LABEL maintainer="Fred Tingaud <ftingaud@hotmail.com>"

USER root

ARG BACKEND_BRANCH=main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    procmail \
    curl \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    npm \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN npm cache clean -f && \
    npm install -g n && \
    n stable

RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    yarn \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    && rm -rf /var/lib/apt/lists/*

ADD https://api.github.com/repos/fredtingaud/quick-bench-back-end/git/refs/heads/${BACKEND_BRANCH} /tmp/backend-version.json

RUN git clone -b ${BACKEND_BRANCH} https://github.com/FredTingaud/quick-bench-back-end /quick-bench && \
    cd /quick-bench && \
    npm install && \
    ./seccomp.js && \
    sysctl -w kernel.perf_event_paranoid=1

ADD https://api.github.com/repos/fredtingaud/quick-bench-front-end/git/refs/heads/main /tmp/frontend-version.json

RUN git clone -b main https://github.com/FredTingaud/quick-bench-front-end /quick-bench/quick-bench-front-end && \
    cd /quick-bench/quick-bench-front-end/build-bench && \
    yarn && \
    yarn build && \
    cd ../quick-bench && \
    yarn && \
    yarn build

COPY ./build-scripts/start-* /quick-bench/

WORKDIR /quick-bench

