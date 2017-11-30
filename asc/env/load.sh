#!/bin/bash

##
# Loads current environment vars and aliases.
#
# This script is idempotent (can be imported many times). Note: combined scripts
# may result in sourcing this file many times over, because for simplicity there
# is no verification preventing this from happening.
#
# Usage :
# . asc/env/load.sh
#

if [[ ! -f "asc/env/current/vars.sh" ]]; then
  echo
  echo "Error in $BASH_SOURCE line $LINENO: no env settings found."
  echo "-> Run asc/stack/init.sh first."
  echo "Aborting (1)."
  return 1
fi

# Load current instance env settings (globals) + ignore readonly errors.
# [wip] TODO evaluate not requiring readonly globals.
# . asc/env/current/vars.sh 2> /dev/null
. asc/env/current/vars.sh

# Load global bash utils.
. asc/bash_utils.sh

# TODO evaluate removing 'registry' feature.
. asc/env/registry.sh

# Load bash aliases.
u_hook_app_call 'bash' 'alias'
