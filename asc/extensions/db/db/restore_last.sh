#!/usr/bin/env bash

##
# Empties database + imports the last dump file.
#
# @param 1 [optional] String : $DB_ID override.
#
# @example
#   make db-restore-last
#   make db-restore-last 'custom_db_id'
#   # Or :
#   asc/extensions/db/db/restore_last.sh
#   asc/extensions/db/db/restore_last.sh 'custom_db_id'
#

. asc/bootstrap.sh
u_db_restore_last "$@"
