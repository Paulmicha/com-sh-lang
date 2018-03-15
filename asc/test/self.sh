#!/usr/bin/env bash

##
# Run ASC core tests (checks ASC itself).
#
# Verifies that the generic ASC functions can successfully run on current host.
#
# @requires running the tests with the same user that will use ASC.
#
# @example
#   asc/test/self.sh
#

. asc/bootstrap.sh

u_fs_file_list asc/test/asc '*.test.sh'

for test_script in $file_list; do
  echo "Executing ASC core $test_script ..."
  asc/test/asc/$test_script
  echo "Executing ASC core $test_script : done."
  echo
done
