#!/usr/bin/env bash

##
# [abstract] Sets instance-level registry value.
#
# Writes to an abstract instance-level storage by given key. "Abstract" means that
# ASC core itself doesn't provide any actual implementation for this
# functionality. It is necessary to use an extension which does. E.g. :
# @see asc/extensions/file_registry
#
# @example
#   asc/instance/registry_set.sh my_key 'my value'
#

. asc/bootstrap.sh
u_instance_registry_set $@
