#!/usr/bin/env bash

##
# [abstract] Triggers a generic 'prompt refine' wrapped command.
#
# @example
#   make prompt-refine $(asc/escape.sh 'Hello "world".')
#   # Or :
#   asc/instance/prompt_refine.sh 'Hello "world".'
#

. asc/bootstrap.sh

prompt_refine_variants='STACK_VERSION PROVISION_USING HOST_OS'

hook -s 'log' -p 'pre' -a 'prompt_refine' -v "$prompt_refine_variants"
hook -s 'gpt' -p 'pre' -a 'prompt_refine' -v "$prompt_refine_variants"

. asc/extensions/gpt/gpt/wrap.sh "$@"

hook -s 'log' -p 'post' -a 'prompt_refine' -v "$prompt_refine_variants"
hook -s 'gpt' -p 'post' -a 'prompt_refine' -v "$prompt_refine_variants"
