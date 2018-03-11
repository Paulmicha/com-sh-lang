#!/usr/bin/env bash

##
# ASC core hook-related tests.
#
# @requires asc/vendor/shunit2
#
# This file may be dynamically executed.
# @see asc/test/asc.sh
#
# @example
#   asc/test/asc/hook.test.sh
#

. asc/bootstrap.sh

##
# Single arg hook : action.
#
# Must trigger lookups
#
test_asc_hook_single_action() {
  local inc_dry_run_files_list=''
  hook -a 'bootstrap' -t -d
  echo "inc_dry_run_files_list = $inc_dry_run_files_list"
  # assertFalse 'Global ASC_INC is empty (bootstrap test failed)' "[ -e $ASC_INC ]"
}

# Load and run shUnit2.
. asc/vendor/shunit2/shunit2
