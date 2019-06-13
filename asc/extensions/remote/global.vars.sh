#!/usr/bin/env bash

##
# Global (env) vars for the 'remote' ASC extension.
#
# This file is used during "instance init" to generate the global environment
# variables specific to current project instance.
#
# @see u_instance_init() in asc/instance/instance.inc.sh
# @see asc/utilities/global.sh
# @see asc/bootstrap.sh
#

# Default path to the SSH public key to use for remote connections. This can be
# overridden per remote instance using the YAML file hook: remote_instances.yml
# @see u_remote_instances_setup() in asc/extensions/remote/remote.inc.sh
global ASC_SSH_PUBKEY "[default]=$HOME/.ssh/id_rsa.pub"
