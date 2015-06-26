dot
===

About
-----

`dot` is a bash script for synchronising personal configuration files (often
colloquially called "dotfiles") using Git repositories.

Usage
-----

`dot` has two modes of operation.

    dot http://user@domain.com/user/repo /path/to/local/file

The above will store the file as `>path>to>local>file` in the specified
repository. Note that the file path cannot contain `>` characters because these
are reserved path characters in the context of `dot`.

    dot http://user@github.com/user/repo

This command is the same as in the first example, but with the second parameter
omitted. This mode pulls all files stored in the repository to the locations
they were pushed from.

**WARNING** `dot` will overwrite any existing files at file paths contained in
the repo.

### Notes

* `dot` does not support removing files from the repository so this must be done
  manually if required.
* `dot.bats` contains unit tests for `dot` and can be used to find out expected
  behaviour.

Installing
----------

`dot` is a single bash script. It can be run from where it's downloaded to,
using bash, or can be made executable using `chmod` and put in a directory in
your `PATH` for convenience.

Tests
-----

Unit tests for `dot` are contained in `dot.bats` and are run using
[bat](https://github.com/sstephenson/bats):

    bats dot.bats
