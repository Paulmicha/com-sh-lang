#!/bin/bash

##
# Drupal app setup.
#
# This script will :
# - write settings
# - create git-ignored instance folders
# - set permissions
# - create instance DB
# - import initial DB dump (requires manual operation : file dumps/initial.sql.gz must exist)
#
# This script is idempotent (can be run several times without issue).
#
# Run as root or sudo.
#
# Usage :
# $ . asc/app/drupal_setup.sh
#

. asc/env/load.sh

. asc/app/write_settings.sh

mkdir -p $APP_DOCROOT/$DRUPAL_FILES_FOLDER
mkdir -p $APP_DOCROOT/$DRUPAL_TMP_FOLDER

. asc/fixperms.sh

. asc/db/setup.sh
. asc/db/import_initial.sh
