#!/usr/bin/env bash

##
# Empties database + imports the last dump file.
#
# @param 1 [optional] String : $DB_NAME override.
#
# @example
#   make db-restore-last
#   make db-restore-last 'custom_db_name'
#   # Or :
#   asc/extensions/db/db/restore_last.sh
#   asc/extensions/db/db/restore_last.sh 'custom_db_name'
#

. asc/bootstrap.sh
u_db_restore_last "$@"
