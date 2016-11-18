#!/bin/bash

# Copyright 2015 Sean Kelleher. All rights reserved.
# Use of this source code is governed by a GPL
# license that can be found in the LICENSE file.

set -o errexit

function quit() {
    echo >&2 "$1"
    exit 1
}

# `handle $f $pat $msg` outputs `$msg` and exits if `$f` contains `$pat`,
# otherwise it outputs the contents of `$f` and exits.
function handle() {
    if grep "$2" "$1" > /dev/null ; then
        quit "$3"
    else
        echo >&2 "An unhandled event occurred:"
        sed >&2 's/^/    /' "$1"
        exit 1
    fi
}

[ -n "$1" -a -n "$2" ] \
    || quit "usage: $0 <repo> <base> [path]"

repo="$1"
shift

# We remove the trailing slash from the base directory if it's present to
# simplify handling paths. The base path is removed from all paths, so by
# removing the trailing slash we cause each path to have a `>` prefix in the
# repository. This prefix allows us to store "meta" files, most notably the
# `.git` directory, alongside the dotfiles in the repository.
base=$(sed 's|/$||' <<< "$1")
shift

! echo "$path" | grep '>' \
    || quit '`path` must not contain ">" after `base` component'

# The `-t` parameter is required for OS X implementation of `mktemp`.
tmpd=$(mktemp -d -t 'tmp.XXXXXXXXXX')
errd=$(mktemp -d -t 'tmp.XXXXXXXXXX')
git clone "$repo" "$tmpd" > /dev/null 2> "$errd/stderr" \
    || handle "$errd/stderr" \
        "bash: git: command not found" "Couldn't find \`git\` command"
cd "$tmpd"

if [ "$#" -gt 0 ] ; then
    while [ "$#" -gt 0 ] ; do
        # Code to get absolute path to file abstracted from
        #
        #     http://stackoverflow.com/a/17577143/497142
        path=$( (
            dir=$(dirname "$1")
            cd "$OLDPWD"
            cd "$dir" 2> "$errd/stderr" \
                || handle "$errd/stderr" \
                    'No such file or directory' "Couldn't open '$dir'"
            abspath=$PWD/$(basename "$1")
            relpath=${abspath#$base}
            if [ -n "$base" -a "$abspath" = "$relpath" ] ; then
                quit "'$abspath' is not in '$base'"
            fi
            echo "$relpath"
        ) )

        name=$(sed 's|/|>|g' <<< $path)
        ln -f "$base$path" "$name" 2> "$errd/stderr" \
            || handle "$errd/stderr" \
                'No such file or directory' "No file at '$base$path'"
        git add "$name"

        shift
    done

    git commit -m . > "$errd/stdout" \
        || handle "$errd/stdout" 'nothing to commit' 'No changes.'
    git push origin master
else
    shopt -s nullglob
    GLOBIGNORE=.git
    for name in * ; do
        path=$base$(sed 's|>|/|g' <<< "$name")
        mkdir -p $(dirname "$path")
        ln -f "$name" "$path"
    done
fi

# TODO Ensure cleanup runs on exit.
rm -rf $tmpd
