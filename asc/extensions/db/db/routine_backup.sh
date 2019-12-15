#!/usr/bin/env bash

##
# Creates a routine DB dump backup + progressively deletes old DB dumps.
#
# @param 1 [optional] String : 'no-purge' to prevent automatic deletion of old
#   backups.
# @param 2 [optional] String : $DB_ID override.
#
# @example
#   make db-routine-backup
#   make db-routine-backup 'no-purge'
#   make db-routine-backup '' 'custom_db_id'
#   make db-routine-backup 'no-purge' 'custom_db_id'
#   # Or :
#   asc/extensions/db/db/routine_backup.sh
#   asc/extensions/db/db/routine_backup.sh 'no-purge'
#   asc/extensions/db/db/routine_backup.sh '' 'custom_db_id'
#   asc/extensions/db/db/routine_backup.sh 'no-purge' 'custom_db_id'
#

. asc/bootstrap.sh
u_db_routine_backup "$@"
