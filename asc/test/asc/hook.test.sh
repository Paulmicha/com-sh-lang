#!/usr/bin/env bash

##
# ASC core hook-related tests.
#
# @requires asc/vendor/shunit2
#
# This file may be dynamically executed.
# @see asc/test/asc.sh
#
# List of acronyms used (must not collide) :
# - nftaschhnc = name for testing ASC hooks hopefully not colliding
# - nftaschdehnc = name for testing ASC hooks dummy extension hopefully not colliding
#
# @example
#   asc/test/asc/hook.test.sh
#

. asc/bootstrap.sh

##
# Creates temporary files for verification purposes in current test case.
#
# (Internal shunit2 function called before all tests have run.)
#
oneTimeSetUp() {
  local s
  for s in $ASC_SUBJECTS; do
    touch "asc/$s/nftaschhnc_dry_run.hook.sh"
  done

  # Also test with a dummy extension (requires bootstrap reload, see below).
  u_asc_get_extensions_dir

  # Failsafe : cannot carry on without an existing ASC extensions dir.
  if [[ ! -d "$extensions_dir" ]]; then
    echo >&2
    echo "Error (3) in $BASH_SOURCE line $LINENO: ASC extensions dir does not exist." >&2
    echo "-> aborting" >&2
    echo >&2
    exit 3
  fi

  mkdir -p "$extensions_dir/nftaschdehnc/app"

  # Failsafe : cannot carry on without successful temporary extension dir creation.
  if [[ $? -ne 0 ]]; then
    echo >&2
    echo "Error (4) in $BASH_SOURCE line $LINENO: cannot create temporary extension dir for testing hooks." >&2
    echo "-> aborting" >&2
    echo >&2
    exit 4
  fi

  mkdir "$extensions_dir/nftaschdehnc/stack"
  mkdir "$extensions_dir/nftaschdehnc/remote"

  touch "$extensions_dir/nftaschdehnc/app/nftaschhnc_dry_run.hook.sh"
  touch "$extensions_dir/nftaschdehnc/stack/nftaschhnc_dry_run.hook.sh"
  touch "$extensions_dir/nftaschdehnc/remote/nftaschhnc_dry_run.hook.sh"

  # Forces detection of our newly created temporary extension.
  u_asc_extend

  echo "  ASC_EXTENSIONS = '$ASC_EXTENSIONS'"
}

##
# Do single action hooks call every matching files ?
#
test_asc_hook_single_action() {
  local inc_dry_run_files_list=''

  echo "  ASC_EXTENSIONS = '$ASC_EXTENSIONS'"

  hook -a 'nftaschhnc_dry_run' -t
  echo "inc_dry_run_files_list = $inc_dry_run_files_list"

  assertTrue 'Global ASC_INC is empty (bootstrap test failed)' "[ -ne $ASC_INC ]"
}

##
# Cleans up any leftovers from previous tests.
#
# (Internal shunit2 function called after all tests have run.)
#
oneTimeTearDown() {
  local s
  for s in $ASC_SUBJECTS; do
    rm -f "asc/$s/nftaschhnc_dry_run.hook.sh"
  done
  u_asc_get_extensions_dir
  rm -fr "$extensions_dir/nftaschdehnc"
}

# Load and run shUnit2.
. asc/vendor/shunit2/shunit2
