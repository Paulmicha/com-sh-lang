#!/usr/bin/env bash

##
# Global (env) vars for the 'docker-compose' ASC extension.
#
# This file is used during "instance init" to generate the global environment
# variables specific to current project instance.
#
# @see u_instance_init() in asc/instance/instance.inc.sh
# @see asc/utilities/global.sh
# @see asc/bootstrap.sh
#

global DC_YML "[default]='$PROJECT_DOCROOT/docker-compose.yml' [help]='Specifies where the generated (& to be git-ignored) docker-compose.yml file will be (over)written.'"

global DC_YML_VARIANTS "[default]='$HOST_TYPE $INSTANCE_TYPE' [help]='Determines which docker-compose.yml \"template\" will be used for current project instance.'"

# [optional] Shorter generated make tasks names.
# @see u_instance_task_name() in asc/instance/instance.inc.sh
global ASC_MAKE_TASKS_SHORTER "[append]='docker-compose/dc'"
