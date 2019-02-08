#!/usr/bin/env bash

##
# [abstract] Clears (empties) database.
#
# @param 1 [optional] String : $DB_NAME override.
#
# This script provides an entry point for triggering a specific hook. "Abstract"
# means that this extension doesn't provide any actual implementation for this
# functionality. In order for this script to have any effect, it is necessary
# to use an extension that does. E.g. :
# @see asc/extensions/mysql
#
# @example
#   make db-clear
#   make db-clear 'custom_db_name'
#   # Or :
#   asc/extensions/db/db/clear.sh
#   asc/extensions/db/db/clear.sh 'custom_db_name'
#

. asc/bootstrap.sh
u_db_clear "$@"
