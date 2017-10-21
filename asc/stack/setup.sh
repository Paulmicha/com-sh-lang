#!/bin/bash

##
# Setup local instance (Debian 8 LAMP version).
#
# Run as root or sudo.
# [wip] TODO adjustments per env type.
#
# Usage :
# $ . asc/stack/setup.sh
#

. asc/env/load.sh

. asc/git/apply_config.sh
. asc/app/drupal_setup.sh
. asc/stack/lamp_deb/cron_drupal_setup.sh

# Domain setup :
# - setup Apache VHost
# - setup (once) certbot auto-renewal cron task for HTTPS / @todo for publicly accessible instances only.
. asc/stack/lamp_deb/vhost_create.sh $INSTANCE_DOMAIN $INSTANCE_ALIAS
. asc/stack/lamp_deb/cron_apache_https_setup.sh
