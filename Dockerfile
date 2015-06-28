# Copyright 2015 Sean Kelleher. All rights reserved.
# Use of this source code is governed by a GPL
# license that can be found in the LICENSE file.

FROM debian:8.0

RUN \
    apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        git

RUN \
    git clone https://github.com/sstephenson/bats.git /usr/local/src/bats && \
    cd /usr/local/src/bats && \
    ./install.sh /usr/local

RUN \
    useradd \
        --create-home \
        dev

COPY \
    dot \
    dot.bats \
    /home/dev/dot/

RUN \
    chown \
        -R \
        dev:dev \
        /home/dev/dot

USER dev

RUN \
    git config --global user.email "dev@example.com" && \
    git config --global user.name "dev"

WORKDIR /home/dev/dot

CMD [ "bats", "dot.bats" ]
