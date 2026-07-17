#!/usr/bin/env bash

##
# List usable GPT models.
#
# @example
#   make gpt-list
#   # Or :
#   asc/extensions/gpt/gpt/list.sh
#

. asc/bootstrap.sh

u_hook_most_specific -s 'gpt' -a 'list' -v 'HOST_OS HOST_TYPE INSTANCE_TYPE'
