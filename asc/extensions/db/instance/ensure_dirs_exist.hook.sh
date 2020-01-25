#!/usr/bin/env bash

##
# Implements hook -s 'app instance' -a 'ensure_dirs_exist'
#
# @see u_instance_init()
#

if [ -n "$ASC_DB_DUMPS_BASE_PATH" ] && [ ! -d "$ASC_DB_DUMPS_BASE_PATH" ]; then
  echo "Creating missing dir '$ASC_DB_DUMPS_BASE_PATH'."
  mkdir -p "$ASC_DB_DUMPS_BASE_PATH"
fi
