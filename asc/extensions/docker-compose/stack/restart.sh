#!/usr/bin/env bash

##
# Docker-compose stack restart action.
#
# @example
#   asc/extensions/docker-compose/stack/restart.sh
#

. asc/bootstrap.sh

docker-compose stop
sleep 1
docker-compose up -d --remove-orphans
sleep 2
