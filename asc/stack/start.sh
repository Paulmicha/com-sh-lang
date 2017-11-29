#!/bin/bash

##
# Starts required services.
#
# @requires asc/stack/setup.sh (must have already been run at least once).
#
# Run as root or sudo.
#
# Usage :
# $ . asc/stack/start.sh
#

. asc/env/load.sh

# Execute the "start" script corresponding to provisioning method.
script="$(u_provisioning_get_script 'stack' 'start')"
if [[ -f "$script" ]]; then
  . "$script"
fi


# Allow custom complements for this script.
u_autoload_get_complement "$BASH_SOURCE"
