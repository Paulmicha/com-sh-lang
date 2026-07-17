#!/usr/bin/env bash

##
# Clears the local ASC cache.
#
# @see asc/bootstrap.sh
# @see asc/utilities/asc.sh
# @see asc/utilities/hook.sh
#
# @example
#   make asc-cache-clear
#   # Or :
#   asc/instance/asc_cache_clear.sh
#

if [[ -d data/asc/cache ]]; then
  rm -rf data/asc/cache
  echo "Cleared local data/asc/cache dir."
fi
