#!/usr/bin/env bash

##
# ASC instance stop action.
#
# This generic implementation is meant for stopping this project instance's
# necessary services on host. It supports variants by :
# - PROVISION_USING
# - INSTANCE_TYPE
# - HOST_TYPE
#
# @see hook()
#
# @example
#   asc/instance/stop.sh
#

. asc/bootstrap.sh

hook -s 'instance' -a 'stop' -v 'PROVISION_USING INSTANCE_TYPE HOST_TYPE'
