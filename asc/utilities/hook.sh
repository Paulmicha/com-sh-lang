#!/bin/bash

##
# Hooks-related utility functions.
#
# This file is dynamically loaded.
# @see asc/bash_utils.sh
#
# Convention : functions names are all prefixed by "u" (for "utility").
#

##
# Sources scripts matching specific path & filename by subject + event (phase).
#
# @requires the following global in calling scope :
# - $PROVISION_USING
#
# @param 1 String : the "subject" (app, env, git, provision, remote, stack).
# @param 2 String : the event name.
# @param 3 [optional] String : the event "phase".
#
# @example 1 : event only
#
#   u_hook_call stack setup
#
#   # Yields the following lookup paths :
#     asc/app/stack/setup.hook.sh
#     asc/app/stack/docker-compose/setup.hook.sh
#     asc/app/stack_setup.hook.sh
#     asc/app/stack_setup.docker-compose.hook.sh
#     asc/env/stack/setup.hook.sh
#     asc/env/stack/docker-compose/setup.hook.sh
#     asc/env/stack_setup.hook.sh
#     asc/env/stack_setup.docker-compose.hook.sh
#     asc/git/stack/setup.hook.sh
#     asc/git/stack/docker-compose/setup.hook.sh
#     asc/git/stack_setup.hook.sh
#     asc/git/stack_setup.docker-compose.hook.sh
#     asc/provision/stack/setup.hook.sh
#     asc/provision/stack/docker-compose/setup.hook.sh
#     asc/provision/stack_setup.hook.sh
#     asc/provision/stack_setup.docker-compose.hook.sh
#     asc/remote/stack/setup.hook.sh
#     asc/remote/stack/docker-compose/setup.hook.sh
#     asc/remote/stack_setup.hook.sh
#     asc/remote/stack_setup.docker-compose.hook.sh
#     asc/stack/docker-compose/setup.hook.sh
#     asc/stack/docker-compose.setup.hook.sh
#
#
# @example 2 : event + phase
#
#   u_hook_call stack init post
#
#   # Yields the following lookup paths :
#     asc/app/stack/post_init.hook.sh
#     asc/app/stack/docker-compose/post_init.hook.sh
#     asc/app/stack_post_init.hook.sh
#     asc/app/stack_post_init.docker-compose.hook.sh
#     asc/env/stack/post_init.hook.sh
#     asc/env/stack/docker-compose/post_init.hook.sh
#     asc/env/stack_post_init.hook.sh
#     asc/env/stack_post_init.docker-compose.hook.sh
#     asc/git/stack/post_init.hook.sh
#     asc/git/stack/docker-compose/post_init.hook.sh
#     asc/git/stack_post_init.hook.sh
#     asc/git/stack_post_init.docker-compose.hook.sh
#     asc/provision/stack/post_init.hook.sh
#     asc/provision/stack/docker-compose/post_init.hook.sh
#     asc/provision/stack_post_init.hook.sh
#     asc/provision/stack_post_init.docker-compose.hook.sh
#     asc/remote/stack/post_init.hook.sh
#     asc/remote/stack/docker-compose/post_init.hook.sh
#     asc/remote/stack_post_init.hook.sh
#     asc/remote/stack_post_init.docker-compose.hook.sh
#     asc/stack/docker-compose.post_init.hook.sh
#     asc/stack/docker-compose/post_init.hook.sh
#
u_hook_call() {
  local p_subject="$1"
  local p_event="$2"
  local p_phase="$3"

  local lookup_paths=()
  local lookup_subject=''
  local lookup_subjects='app env git provision remote stack'

  if [[ -z "$p_phase" ]]; then
    for lookup_subject in $lookup_subjects; do

      if [[ "$lookup_subject" != "$p_subject" ]]; then
        lookup_paths+=("asc/$lookup_subject/${p_subject}/${p_event}.hook.sh")
        u_autoload_add_lookup_level "asc/$lookup_subject/${p_subject}/" "${p_event}.hook.sh" "$PROVISION_USING" lookup_paths '' '/'

        lookup_paths+=("asc/$lookup_subject/${p_subject}_${p_event}.hook.sh")
        u_autoload_add_lookup_level "asc/$lookup_subject/${p_subject}_${p_event}." "hook.sh" "$PROVISION_USING" lookup_paths

      else
        u_autoload_add_lookup_level "asc/${p_subject}/" "${p_event}.hook.sh" "$PROVISION_USING" lookup_paths '' '/'
        u_autoload_add_lookup_level "asc/${p_subject}/" "${p_event}.hook.sh" "$PROVISION_USING" lookup_paths
      fi
    done

  else
    for lookup_subject in $lookup_subjects; do

      if [[ "$lookup_subject" != "$p_subject" ]]; then
        lookup_paths+=("asc/$lookup_subject/${p_subject}/${p_phase}_${p_event}.hook.sh")
        u_autoload_add_lookup_level "asc/$lookup_subject/${p_subject}/" "${p_phase}_${p_event}.hook.sh" "$PROVISION_USING" lookup_paths '' '/'

        lookup_paths+=("asc/$lookup_subject/${p_subject}_${p_phase}_${p_event}.hook.sh")
        u_autoload_add_lookup_level "asc/$lookup_subject/${p_subject}_${p_phase}_${p_event}." "hook.sh" "$PROVISION_USING" lookup_paths

      else
        u_autoload_add_lookup_level "asc/${p_subject}/" "${p_phase}_${p_event}.hook.sh" "$PROVISION_USING" lookup_paths
        u_autoload_add_lookup_level "asc/${p_subject}/" "${p_phase}_${p_event}.hook.sh" "$PROVISION_USING" lookup_paths '' '/'
      fi
    done
  fi

  # Debug.
  # u_autoload_print_lookup_paths lookup_paths "u_hook_call $p_subject $p_event $p_phase"

  local hook_script=''
  for hook_script in "${lookup_paths[@]}"; do
    if [[ -f "$hook_script" ]]; then
      eval $(u_autoload_override "$hook_script" 'continue')
      . "$hook_script"
    fi
    u_autoload_get_complement "$hook_script"
  done
}
