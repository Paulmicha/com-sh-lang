#!/usr/bin/env bash

##
# Implements hook -s 'instance' -p 'pre' -a 'start' -v 'STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
#
# Makes sure DB-related env. vars. get exported for extensions which need them
# during this action - e.g. docker-compose.
#
# @see asc/instance/start.sh
# @see asc/extensions/docker-compose/instance/start.docker-compose.hook.sh
#

u_db_set_all
