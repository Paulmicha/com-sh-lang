#!/usr/bin/env bash

##
# (over)Writes Git hooks to use ASC hooks.
#
# @example
#   asc/git/write_hooks.sh
#

. asc/bootstrap.sh
u_git_write_hooks "$@"
