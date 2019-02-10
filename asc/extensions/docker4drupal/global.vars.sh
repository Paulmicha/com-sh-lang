#!/usr/bin/env bash

##
# Global (env) vars for the 'docker4drupal' ASC extension.
#
# This file is used during "instance init" to generate the global environment
# variables specific to current project instance.
#
# @see u_instance_init() in asc/instance/instance.inc.sh
# @see asc/utilities/global.sh
# @see asc/bootstrap.sh
#

# Default aliases need container names for php and database containers.
# @see asc/extensions/docker4drupal/asc/bootstrap.docker-compose.hook.sh
# Redis container name is also necessary for default Drupal settings.
# @see asc/extensions/docker4drupal/app/drupal_settings.7.tpl.php
global D4D_PHP_SNAME "[default]=php"
global D4D_DB_SNAME "[default]=mariadb"
global D4D_REDIS_SNAME "[default]=redis"

# Make the automatic crontab setup for Drupal cron on local host during 'app
# install' opt-in.
global D4D_USE_CRONTAB "[default]=false"

# [optional] Shorter generated make tasks names.
# @see u_instance_task_name() in asc/instance/instance.inc.sh
global ASC_MAKE_TASKS_SHORTER "[append]='docker4drupal/d4d'"
