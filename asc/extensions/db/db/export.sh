#!/usr/bin/env bash

##
# [abstract] Exports database to a dump file.
#
# @param 1 String : the dump file path.
# @param 2 [optional] String : $DB_NAME override.
#
# This script provides an entry point for triggering a specific hook. "Abstract"
# means that this extension doesn't provide any actual implementation for this
# functionality. In order for this script to have any effect, it is necessary
# to use an extension that does. E.g. :
# @see asc/extensions/mysql
#
# Important note : implementations of the hook -s 'db' -a 'export' MUST use the
# following variable in calling scope as output path (resulting file) :
# @var db_dump_file
#
# @example
#   asc/extensions/db/db/export.sh '/path/to/dump/file.sql'
#   asc/extensions/db/db/export.sh '/path/to/dump/file.sql' 'custom_db_name'
#

. asc/bootstrap.sh
u_db_export "$@"
