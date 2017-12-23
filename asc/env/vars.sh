#!/usr/bin/env bash

##
# Global env settings declaration.
#
# This file is dynamically included during stack init. Matching rules and syntax
# are explained in documentation.
# @see asc/env/README.md
#
# TODO provide tests / CI examples.
#

# Scripts should consider that any STATE value is an error, except for OK_STATES.
# NB : the STATE global variable is first defined during bootstrap.
# @see asc/bootstrap.sh
global OK_STATES "[default]='installed initialized running'"

# These global variables are essential ASC internal values. Each has a
# corresponding argument in the asc/stack/init.sh script.
# @see asc/stack/init/get_args.sh
global PROJECT_STACK
global PROJECT_DOCROOT "[default]=$PWD"
global APP_DOCROOT "[default]=$PROJECT_DOCROOT/web"
global INSTANCE_TYPE "[default]=dev"
global INSTANCE_DOMAIN "[default]='$(u_get_instance_domain)'"
global INSTANCE_ALIAS

# This allows supportting multi-repo projects, e.g. 1 repo for the app, 1 for
# the "dev stack", or any other combination of any number of repos.
# Use ASC_MODE='monolithic' for single-repo projects.
# Use ASC_MODE='separate' for multi-repo projects (mandatory app Git details).
global ASC_MODE "[default]=separate"
global APP_GIT_ORIGIN "[if-ASC_MODE]=separate"
global APP_GIT_WORK_TREE "[if-ASC_MODE]=separate [default]=$APP_DOCROOT"

# These values are used to generate lookup paths in hooks (events), overrides
# and/or complements.
# @see asc/custom/README.md
global HOST_TYPE "[default]=local"
global HOST_OS "[default]='$(u_host_get_os)'"
global PROVISION_USING "[default]=docker-compose"
global DEPLOY_USING "[default]=git"

# TODO evaluate removal of "registry" feature.
global REG_BACKEND "[default]=file"
# TODO else consider using a separate store for secrets, see asc/env/README.md.
# global SECRETS_BACKEND

# This path indicates where presets, overrides and complements are to be found.
# That folder should contain current project's private (or "vendor") includes
# used to generate lookup paths in hooks (events), overrides and/or complements.
global ASC_CUSTOM_DIR "[default]=asc/custom"
