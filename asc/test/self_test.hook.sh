#!/usr/bin/env bash

##
# Implements hook -s 'test' -a 'self_test' -v 'HOST_TYPE PROVISION_USING'.
#
# Runs ASC core tests (checks ASC itself). Verifies that the generic ASC
# functions can successfully run on current host.
#
# @requires running the tests with the same user that will use ASC.
#
# @see u_test_batch_exec() in asc/test/test.inc.sh
#
# @example
#   make self-test
#   # Or :
#   asc/test/self_test.sh
#

u_test_batch_exec 'asc/test/asc'
