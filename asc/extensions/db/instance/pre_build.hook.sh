#!/usr/bin/env bash

##
# Implements hook -s 'instance' -p 'pre' -a 'build' -v 'PROVISION_USING HOST_TYPE INSTANCE_TYPE'
#
# Makes sure DB-related env. vars. get exported for extensions which need them
# during this action - e.g. docker-compose.
#
# @see asc/instance/build.sh
# @see asc/extensions/docker-compose/instance/build.docker-compose.hook.sh
#

u_db_get_credentials
