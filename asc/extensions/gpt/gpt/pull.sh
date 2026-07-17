#!/usr/bin/env bash

##
# List usable GPT models.
#
# @example
#   make gpt-pull
#   # Or :
#   asc/extensions/gpt/gpt/pull.sh
#

. asc/bootstrap.sh

u_hook_most_specific -s 'gpt' -a 'pull' -v 'HOST_OS HOST_TYPE INSTANCE_TYPE'
