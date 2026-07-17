#!/usr/bin/env bash

##
# Logged gpt composition: log/wrap → thread/gpt.
#
# @example
#   make logged-gpt e:blueprint-generate e:transcribe-all
#   # Or :
#   asc/instance/logged_gpt.sh e:blueprint-generate e:transcribe-all
#

. asc/bootstrap.sh

logged_gpt_variants='STACK_VERSION PROVISION_USING HOST_OS'

hook -s 'log' -p 'pre' -a 'logged_gpt' -v "$logged_gpt_variants"
hook -s 'gpt' -p 'pre' -a 'logged_gpt' -v "$logged_gpt_variants"

asc/log/wrap.sh asc/extensions/gpt/gpt/wrap.sh "$@"

hook -s 'log' -p 'post' -a 'logged_gpt' -v "$logged_gpt_variants"
hook -s 'gpt' -p 'post' -a 'logged_gpt' -v "$logged_gpt_variants"
