#!/usr/bin/env bash

##
# Global (env) vars for drupalwt extension provisionned using docker-compose.
#
# Provides service names (containers) for use in bash aliases.
# @see asc/extensions/drupalwt/asc/bootstrap.docker-compose.hook.sh
#
# This file is used during "instance init" to generate the global environment
# variables specific to current project instance.
#
# @see u_instance_init() in asc/instance/instance.inc.sh
# @see asc/utilities/global.sh
# @see asc/bootstrap.sh
#

# Redis container name is also necessary for default Drupal settings.
# @see asc/extensions/drupalwt/app/drupal_settings.7.tpl.php
global PHP_SNAME "[default]=php"
global REDIS_SNAME "[default]=redis"
