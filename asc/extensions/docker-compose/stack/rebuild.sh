#!/usr/bin/env bash

##
# Docker-compose stack restart action.
#
# @example
#   asc/extensions/docker-compose/stack/rebuild.sh
#

. asc/bootstrap.sh

docker-compose stop
sleep 1
docker-compose build
sleep 2
