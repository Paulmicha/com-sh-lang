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

# Advanced usage : allows swapping global namespace at runtime. Used for
# exporting dynamic global variables names.
# NB : not every global is namespaced. The hardcoded ones are to be considered
# ASC internal globals.
# @see u_asc_extend()
if [[ -z "$NAMESPACE" ]]; then
  export NAMESPACE='ASC'
fi

# Makes sure bootstrap runs once per namespace.
eval "once=\$${NAMESPACE}_BS_FLAG"
if [[ -z "$once" ]]; then
  eval "export ${NAMESPACE}_BS_FLAG=1"

  # Include required utilities.
  . asc/utilities/autoload.sh # TODO include once (convenience).
  for file in $(find asc/utilities/* -type f -print0 | xargs -0); do
    . "$file"
    u_autoload_get_complement "$file"
  done

  # TODO [wip] workaround instance state limitations (e.g. unhandled shutdown).
  u_instance_get_state

  # Initializes hooks and lookups (ASC extension mecanisms).
  u_asc_extend

  # Load optional additional includes.
  if [[ -n "$ASC_INC" ]]; then
    for file in $ASC_INC; do
      . "$file"
      u_autoload_get_complement "$file"
    done
  fi

  # If stack init was run at least once, automatically load global env vars.
  if [[ -f "asc/env/current/vars.sh" ]]; then
    . asc/env/load.sh
  fi

  # Call any 'bootstrap' hooks.
  u_hook 'asc' 'bootstrap'
fi
