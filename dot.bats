#!/usr/bin/env bats

# Copyright 2015 Sean Kelleher. All rights reserved.
# Use of this source code is governed by a GPL
# license that can be found in the LICENSE file.

dot=$PWD/dot

setup() {
    export tmpd=$(mktemp -d -t tmp)
    cd "$tmpd"

    export repo=$(mktemp -d -t tmp)
    git init --bare "$repo" | sed 's/^/[SETUP] /'
}

@test '`dot` outputs usage message' {
    run bash "$dot"
    [ "$status" -eq 1 ]
    [ "$output" = "usage: $dot <repo> [path]" ]
}

@test '`dot $repo file` adds `file` to `$repo`' {
    echo 'initial' > file

    run bash "$dot" "$repo" file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/* file
}

@test '`dot $repo dir/file` adds `dir>file` to `$repo`' {
    mkdir dir
    echo 'initial' > dir/file

    run bash "$dot" "$repo" dir/file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    [ "$(ls repo | wc -l)" -eq 1 ]
    ls repo | grep 'dir>file$'
    diff repo/* dir/file
}

@test '`dot $repo file` when `file` unchanged outputs "No changes."' {
    echo 'initial' > file
    bash "$dot" "$repo" file

    run bash "$dot" "$repo" file
    [ "$status" -eq 1 ]
    [ "$output" = "No changes." ]
}

@test '`dot $repo file` overwrites `file` in `$repo`' {
    echo 'initial' > file
    bash "$dot" "$repo" file

    git clone "$repo" repo
    diff repo/* file
    rm -rf repo

    echo 'update' > file
    bash "$dot" "$repo" file

    git clone "$repo" repo
    diff repo/* file
}

@test '`dot $repo` creates `file` from `$repo` if missing' {
    echo 'initial' > file
    bash "$dot" "$repo" file
    mv file file.bak

    run bash "$dot" "$repo"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff file file.bak
}

@test '`dot $repo` creates path to `file` from `$repo` if missing' {
    mkdir dir
    echo 'initial' > dir/file
    bash "$dot" "$repo" dir/file
    mv dir dir.bak

    run bash "$dot" "$repo"
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff dir/file dir.bak/file
}

@test '`dot $repo` overwrites file if exists' {
    echo 'initial' > file
    bash "$dot" "$repo" file

    cp file file.bak
    echo 'update' > file

    run bash "$dot" "$repo"
    echo $output
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff file file.bak
}
