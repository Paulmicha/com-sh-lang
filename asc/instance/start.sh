#!/usr/bin/env bash

##
# ASC instance start action.
#
# This generic implementation is meant for starting this project instance's
# necessary services on host. It supports variants by :
# - PROVISION_USING
# - INSTANCE_TYPE
# - HOST_TYPE
#
# @see hook()
#
# @example
#   asc/instance/start.sh
#

. asc/bootstrap.sh

hook -s 'instance app' -a 'start' -v 'PROVISION_USING INSTANCE_TYPE HOST_TYPE'
