#!/usr/bin/env bash

##
# Implements hook -p 'post' -a 'init'.
#
# Warms up the local ASC cache for just a bunch of usual hooks.
#
# @see asc/bootstrap.sh
# @see asc/utilities/hook.sh
#
# @example
#   make asc-cache-warmup
#   # Or :
#   asc/instance/asc_cache_warmup.sh
#

echo "Warming up a bunch of ASC hooks cache ..."

hook -w -s 'instance' -p 'pre' -a 'start' -v 'STACK_VERSION STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
hook -w -s 'instance' -a 'start' -v 'STACK_VERSION STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
hook -w -s 'instance' -p 'post' -a 'start' -v 'STACK_VERSION STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
hook -w -s 'instance' -p 'pre' -a 'stop' -v 'STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
hook -w -s 'instance' -a 'stop' -v 'STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
hook -w -s 'instance' -p 'post' -a 'stop' -v 'STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
hook -w -s 'instance' -p 'stage2' -a 'setup' -v 'STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
hook -w -s 'instance' -p 'post' -a 'setup' -v 'STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'

# Hooks related to file ownership & permissions.
# @see asc/instance/fs_perms_set.hook.sh
# @see asc/instance/fs_ownership_set.hook.sh
subjects='app'

if [[ -n "$ASC_APPS" ]]; then
  subjects="$ASC_APPS"
fi

actions='
fs_ownership_get
fs_ownership_pre_set
fs_ownership_set
fs_ownership_post_set
fs_perms_get
fs_perms_pre_set
fs_perms_set
fs_perms_post_set
'

for action in $actions; do
  hook -w -s "$subjects instance" -a "$action" -v 'STACK_VERSION PROVISION_USING HOST_TYPE INSTANCE_TYPE'
done

echo "Warming up a bunch of ASC hooks cache : done."
echo
