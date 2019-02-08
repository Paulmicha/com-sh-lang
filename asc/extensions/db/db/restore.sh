#!/usr/bin/env bash

##
# Empties database + imports given dump file.
#
# @param 1 String : the dump file path.
# @param 2 [optional] String : $DB_NAME override.
#
# @example
#   make db-restore '/path/to/dump/file.sql'
#   make db-restore '/path/to/dump/file.sql' 'custom_db_name'
#   # Or :
#   asc/extensions/db/db/restore.sh '/path/to/dump/file.sql'
#   asc/extensions/db/db/restore.sh '/path/to/dump/file.sql' 'custom_db_name'
#

. asc/bootstrap.sh
u_db_restore "$@"
