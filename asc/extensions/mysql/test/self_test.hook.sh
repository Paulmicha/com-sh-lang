#!/usr/bin/env bash

##
# Implements hook -s 'test' -a 'self_test' -v 'HOST_TYPE PROVISION_USING'.
#
# Verifies current instance can execute MySQL actions normally.
#
# @see u_test_batch_exec() in asc/test/test.inc.sh
#
# @example
#   make self-test
#   asc/test/self_test.sh
#

u_test_batch_exec 'asc/extensions/mysql/test/mysql'
