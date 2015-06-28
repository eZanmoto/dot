#!/bin/bash

# Copyright 2015 Sean Kelleher. All rights reserved.
# Use of this source code is governed by a GPL
# license that can be found in the LICENSE file.

if [ "$1" = '-v' ] ; then
    logf=/dev/stdout
else
    logf=$(mktemp -t 'tmp.XXXXXXXXXX')
fi

# We tag `dot:latest` with `dot:prev` so that we can remove the old image if
# we're not using its cached layers (`docker rmi` will stop us from removing the
# image if another image is using its layers).
docker tag --force dot:latest dot:prev >> "$logf" 2>&1
trap 'docker rmi dot:prev &> /dev/null' ERR

docker build --rm --tag=dot:latest . >> "$logf" 2>&1 || {
    if [ "$logf" != /dev/stdout ] ; then
        cat "$logf"
    fi
    exit 1
}

# We allocate a pseudo-TTY so that we can kill the command interactively.
docker run --rm --tty dot:latest
