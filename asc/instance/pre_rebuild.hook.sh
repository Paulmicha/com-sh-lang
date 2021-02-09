#!/usr/bin/env bash

##
# Implements hook -s 'instance' -p 'pre' -a 'rebuild' -v 'PROVISION_USING HOST_TYPE INSTANCE_TYPE'
#
# Rewrites locally generated ASC files - e.g. docker-compose.yml, settings
# files, etc. based on the values previously set for the following global global
# env. vars :
# - $INSTANCE_TYPE
# - $INSTANCE_DOMAIN
# - $HOST_TYPE
# - $PROVISION_USING
#
# @see asc/instance/reinit.sh
# @see asc/instance/rebuild.sh
#

# TODO confirm and remove "env -i" if not needed.
env -i \
  ASC_SSH_PUBKEY="$ASC_SSH_PUBKEY" \
  ASC_DB_ID="$ASC_DB_ID" \
  HOME="$HOME" LC_CTYPE="${LC_ALL:-${LC_CTYPE:-$LANG}}" PATH="$PATH" USER="$USER" \
  asc/instance/reinit.sh
