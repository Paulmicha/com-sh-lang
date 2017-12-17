#!/usr/bin/env bash

##
# Bootstraps ASC.
#
# Loads includes containing bash functions + call optional bootstrap hooks.
#
# TODO [wip] evaluating not resetting these globals on every call to bootstrap.
# This is to allow presets to be organized like the asc folder (extensibility).
#
# @example
#   . asc/bootstrap.sh
#

# Measure time elapsed.
SECONDS=0

# This allows to customize ASC extensibility.
export ASC_EXTENSIONS

# Include required utilities.
. asc/utilities/autoload.sh
for file in $(find asc/utilities/* -type f -print0 | xargs -0); do
  . "$file"
  u_autoload_get_complement "$file"
done

echo
echo "Seconds elapsed - include required utilities = $SECONDS"
echo

# Initializes hooks and lookups (ASC extension mecanisms).
u_asc_extend

echo
echo "Seconds elapsed - u_asc_extend = $SECONDS"
echo

# Load optional additional includes.
if [[ -n "$ASC_INC" ]]; then
  for file in $ASC_INC; do
    . "$file"
    u_autoload_get_complement "$file"
  done
fi

echo
echo "Seconds elapsed - optional additional includes = $SECONDS"
echo

# Call any 'bootstrap' hooks.
u_hook 'asc' 'bootstrap'

echo
echo "Seconds elapsed - u_hook 'asc' 'bootstrap' = $SECONDS"
echo
