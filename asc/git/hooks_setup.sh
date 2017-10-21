#!/bin/bash

##
# Git hooks setup.
#
# [wip]
#
# Usage from project root dir :
# $ . asc/git/hooks_setup.sh
#

ln -s asc/git/hooks/pre_commit.sh .git/hooks/pre-commit
