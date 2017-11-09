#!/bin/bash

##
# [wip] Init environment settings for this project intance.
#
# Prerequisites:
# Local Git repo initialized. See main README.md - section "Usage".
#
# This script will dynamically generate and (over)write settings based on
# the following values :
# 1. type of storage to use for ASC env settings on current host
# 2. provisioning method
# 3. project stack
# 4. instance type
# 5. instance domain
# 6. [wip] deploy method
# 7. [wip] testing (preset)
#
# Usage examples :
# $ . asc/stack/init.sh                 # Will prompt to confirm/edit every default value
# $ . asc/stack/init.sh -y              # Will use default values
# $ . asc/stack/init.sh -s drupal-7     # Short name/value argument syntax
# $ . asc/stack/init.sh --stack=drupal-7 --yes      # Longer name/value argument syntax (equivalent)
#

. asc/bash_utils.sh

# Get named script arguments.
. asc/stack/init/arguments.sh

# These values are needed throughout this task's related scripts.
export ENV_VARS
export PROJECT_STACK="$P_PROJECT_STACK"
export CURRENT_ENV_SETTINGS_FILE='asc/env/current/vars.sh'

if [[ -z "$PROJECT_STACK" ]]; then
  echo "Warning in $BASH_SOURCE line $LINENO: cannot carry on without a value for \$P_PROJECT_STACK."
  return
fi

# Arguments matching + default value fallback.
# WIP / TODO
. asc/stack/init/match_args_w_env_vars.sh

# Aggregates env vars.
declare -A ENV_VARS
. asc/stack/init/aggregate_env_vars.sh

# Write in current instance env settings file.
# WIP / TODO
. asc/env/write.sh
