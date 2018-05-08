#!/usr/bin/env bash

##
# ASC app install action.
#
# This generic implementation is meant to setup the application if it requires
# e.g. a database to be initialiazed, an initial DB dump to be imported, etc.
#
# It supports variants by :
# - PROVISION_USING
# - INSTANCE_TYPE
# @see hook()
#
# @prereq stack services must be running (see 'instance start' action).
# @see asc/instance/start.sh
#
# @example
#   asc/app/install.sh
#

. asc/bootstrap.sh

hook -a 'install' -s 'app' -v 'PROVISION_USING INSTANCE_TYPE'
