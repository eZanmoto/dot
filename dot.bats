#!/usr/bin/env bats

# Copyright 2015 Sean Kelleher. All rights reserved.
# Use of this source code is governed by a GPL
# license that can be found in the LICENSE file.

dot=$PWD/dot

setup() {
    cd "$(mktemp -d -t tmp)"

    export repo=$(mktemp -d -t tmp)
    git init --bare "$repo" | sed 's/^/[SETUP] /'
}

@test '`dot` outputs usage message' {
    run bash "$dot"
    [ "$status" -eq 1 ]
    [ "$output" = "usage: $dot <repo> <base> [path]" ]
}

@test '`dot $repo` outputs usage message' {
    run bash "$dot" "$repo"
    [ "$status" -eq 1 ]
    [ "$output" = "usage: $dot <repo> <base> [path]" ]
}

@test '`dot $repo $PWD/a b/file` outputs error message' {
    mkdir b
    run bash "$dot" "$repo" "$PWD/a" "b/file"
    [ "$status" -eq 1 ]
    [ "$output" = "'$PWD/b/file' is not in '$PWD/a'" ]
}

@test '`dot $repo $PWD file` adds `>file` to `$repo`' {
    echo 'initial' > file

    run bash "$dot" "$repo" "$PWD" file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/'>file' file
}

@test '`dot $repo $PWD file` does not modify directory' {
    echo 'initial' > file
    old=$(ls -A)

    run bash "$dot" "$repo" "$PWD" file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    [ "$old" = $(ls -A) ]
}

@test '`dot $repo $PWD .git` adds `>.git` to `$repo`' {
    echo 'initial' > .git

    run bash "$dot" "$repo" "$PWD" .git
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/'>.git' .git
}

@test '`dot $repo / $PWD/file` adds file to `$repo`' {
    echo 'initial' > file

    run bash "$dot" "$repo" / "$PWD"/file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/*file file
}

@test '`dot $repo $PWD a b` adds `>a` and `>b` to `$repo`' {
    echo 'a' > a
    echo 'b' > b

    run bash "$dot" "$repo" "$PWD" a b
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/'>a' a
    diff repo/'>b' b
}

@test '`dot $repo $PWD file` outputs error if `file` missing' {
    run bash "$dot" "$repo" "$PWD" file
    [ "$status" -eq 1 ]
    echo $output
    echo "No file at '$PWD/file'"
    [ "$output" = "No file at '$PWD/file'" ]
}

@test '`dot $repo $PWD dir/file` adds `>dir>file` to `$repo`' {
    mkdir dir
    echo 'initial' > dir/file

    run bash "$dot" "$repo" "$PWD" dir/file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/'>dir>file' dir/file
}

@test '`dot $repo $PWD dir/file` outputs error if `dir` missing' {
    run bash "$dot" "$repo" "$PWD" dir/file
    [ "$status" -eq 1 ]
    [ "$output" = "Couldn't open 'dir'" ]
}

@test '`dot $repo $PWD dir/dir/file` adds `>dir>dir>file` to `$repo`' {
    mkdir -p dir/dir
    echo 'initial' > dir/dir/file

    run bash "$dot" "$repo" "$PWD" dir/dir/file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/'>dir>dir>file' dir/dir/file
}

@test '`dot $repo $PWD/dir dir/dir/file` adds `>dir>file` to `$repo`' {
    mkdir -p dir/dir
    echo 'initial' > dir/dir/file

    run bash "$dot" "$repo" "$PWD/dir" dir/dir/file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    git clone "$repo" repo
    diff repo/'>dir>file' dir/dir/file
}

@test '`dot $repo $PWD file` when `file` unchanged outputs "No changes."' {
    echo 'initial' > file
    bash "$dot" "$repo" "$PWD" file

    run bash "$dot" "$repo" "$PWD" file
    [ "$status" -eq 1 ]
    [ "$output" = "No changes." ]
}

@test '`dot $repo $PWD file` overwrites `file` in `$repo`' {
    echo 'initial' > file
    bash "$dot" "$repo" "$PWD" file

    git clone "$repo" repo
    diff repo/'>file' file
    rm -rf repo

    echo 'update' > file
    bash "$dot" "$repo" "$PWD" file

    git clone "$repo" repo
    diff repo/'>file' file
}

@test '`dot $repo $PWD` creates `file` from `$repo` if missing' {
    echo 'initial' > file
    bash "$dot" "$repo" "$PWD" file
    mv file file.bak

    run bash "$dot" "$repo" "$PWD"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff file file.bak
}

@test '`dot $repo $PWD` creates path to `file` from `$repo` if missing' {
    mkdir dir
    echo 'initial' > dir/file
    bash "$dot" "$repo" "$PWD" dir/file
    mv dir dir.bak

    run bash "$dot" "$repo" "$PWD"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff dir/file dir.bak/file
}

@test '`dot $repo $PWD` overwrites file if exists' {
    echo 'initial' > file
    bash "$dot" "$repo" "$PWD" file

    cp file file.bak
    echo 'update' > file

    run bash "$dot" "$repo" "$PWD"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff file file.bak
}

@test '`dot $repo $PWD` retrieves multiple files from `$repo`' {
    echo 'a' > a
    echo 'b' > b
    bash "$dot" "$repo" "$PWD" a b

    mv a a.bak
    mv b b.bak

    bash "$dot" "$repo" "$PWD"

    diff a a.bak
    diff b b.bak
}

@test '`dot $repo $PWD` retrieves hidden files in `$repo`' {
    echo 'initial' > .file
    run bash "$dot" "$repo" "$PWD" .file
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    mv .file .file.bak

    run bash "$dot" "$repo" "$PWD"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff .file .file.bak
}

@test '`dot $repo $PWD` retrieves files with whitespace in `$repo`' {
    echo 'first' > 'a tricky name'
    run bash "$dot" "$repo" "$PWD" 'a tricky name'
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    mv 'a tricky name' 'a tricky name.bak'

    run bash "$dot" "$repo" "$PWD"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff 'a tricky name' 'a tricky name.bak'
}

@test '`dot $repo $PWD/b` retrieves `file` pushed from `$PWD/a`' {
    mkdir a
    echo 'initial' > a/file
    bash "$dot" "$repo" "$PWD/a" a/file

    run bash "$dot" "$repo" "$PWD/b"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    diff a/file b/file
}
