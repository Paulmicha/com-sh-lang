#!/usr/bin/env bash

##
# Triggers a generic 'restart' operation for this project instance.
#
# This merely chains 'stop' and 'start' actions.
# @see asc/instance/stop.sh
# @see asc/instance/start.sh
#
# @example
#   make restart
#   # Or :
#   asc/instance/restart.sh
#

. asc/instance/stop.sh
. asc/instance/start.sh
