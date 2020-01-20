#!/usr/bin/env bash

##
# Implements hook -p 'post' -a 'init' -v 'PROVISION_USING HOST_TYPE INSTANCE_TYPE'.
#
# @see u_dwt_write_settings() in asc/extensions/drupalwt/drupalwt.inc.sh
# @see u_instance_init() in asc/instance/instance.inc.sh
#

u_dwt_write_settings
