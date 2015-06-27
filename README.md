dot
===

About
-----

`dot` is a bash script for synchronising personal configuration files (often
colloquially called "dotfiles") using Git repositories. See
[dotfiles](https://github.com/eZanmoto/dotfiles) for an example repository using
this approach.

Usage
-----

### Summary

    dot repo-address /home/user1 .your .dot .files

Stores the `.your`, `.dot`, and `.files` files in the repository you specify
(local or remote) and removes their `/home/user1` prefix.

    dot repo-address /home/user2

Retrieves the files you stored in the repository and saves them locally,
relative to `/home/user2`

**WARNING** `dot` will overwrite any existing files at file paths contained in
the repository.

### Details

The arguments to `dot` are as follows:

    dot <repo> <base> [paths*]

`dot` has two modes of operation, based on whether the optional path arguments
are supplied.

    dot http://user@domain.com/user/repo /path/to /path/to/a/dot/file other/file

Assuming we are in `/path/to/the`, the above will store `/path/to/a/dot/file` as
`a>dot>file` and `other/file` as `the>local>file` in the specified repository.
Note that file paths cannot contain `>` characters because these are reserved
path characters in the context of `dot`. Also note that the file paths may be
relative to the current directory but the base path (`/path/to` in this example)
must be absolute.

    dot http://user@github.com/user/repo /path/to

This command is the same as in the first example, but with the optional paths
omitted. This mode pulls all files stored in the repository to the locations
they were pushed from, relative to the base path.

### Notes

* `dot` does not support removing files from the repository so this must be done
  manually if required.
* `dot.bats` contains unit tests for `dot` and can be used to find out expected
  behaviour.

Installing
----------

`dot` is a single bash script. It can be run from where it was downloaded, using
bash, or can be made executable using `chmod` and put in a directory in your
`PATH` for convenience.

A useful shortcut is to add an alias for `dot` to your shell initialisation
script that contains the repository address:

    alias dot='bash /path/to/dot http://user@github.com/user/repo'

This simplifies the commands to just be `dot` and `dot /path/to/local/file`. We
can also sync our shell initialisation script using `dot` which means that we
only need to create our alias once.

Tests
-----

Unit tests for `dot` are contained in `dot.bats` and are run using
[bat](https://github.com/sstephenson/bats):

    bats dot.bats
