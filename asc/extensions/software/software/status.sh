#!/usr/bin/env bash

##
# Software status: compare manifests to installed tools (no apply).
#
# @example
#   make software-status
#   # Or :
#   asc/extensions/software/software/status.sh
#

. asc/bootstrap.sh

u_software_provision status
