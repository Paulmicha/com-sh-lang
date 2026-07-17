#!/usr/bin/env bash

##
# Abstract local LLM bring-up: bootstrap → most-specific hook.
#
# @example
#   make gpt-stop
#   # Or :
#   asc/extensions/gpt/gpt/stop.sh
#

. asc/bootstrap.sh

u_hook_most_specific -s 'gpt' -a 'stop' -v 'HOST_OS HOST_TYPE INSTANCE_TYPE'
