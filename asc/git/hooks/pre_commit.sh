#!/usr/bin/env bash

##
# Implements Git 'pre-commit' hook.
#
# @see asc/git/hooks_setup.sh
#

# Include globals, aliases, utility functions (ASC).
. asc/bootstrap.sh

# (Re)set file system ownership and permissions.
hook -s 'app instance' -a 'set_fsop'

# Re-add previously staged files in case their permissions have changed.
staged="$(u_git_get_staged_files "$APP_GIT_WORK_TREE")"
for f in $staged; do
  u_git_wrapper add "$f"
done
