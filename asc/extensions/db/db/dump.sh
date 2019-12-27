#!/usr/bin/env bash

##
# Creates a routine DB dump.
#
# @param 1 [optional] String : $DB_ID override.
#
# @example
#   make db-dump
#   make db-dump 'custom_db_id'
#   # Or :
#   asc/extensions/db/db/dump.sh
#   asc/extensions/db/db/dump.sh 'custom_db_id'
#

. asc/bootstrap.sh
u_db_routine_backup 'no-purge' "$@"
