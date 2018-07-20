#!/usr/bin/env bash

##
# Builds this project instance's necessary services.
#
# @example
#   make instance-build
#   asc/extensions/docker-compose/instance/build.sh
#

. asc/bootstrap.sh

hook -s 'instance app' -a 'build' -v 'PROVISION_USING HOST_TYPE INSTANCE_TYPE'
