
##
# ASC main Makefile.
#
# This makefile is just a "hub" to optionally include any *.mk files found.
# @see asc/env/current/README.md
#

-include .env

# TODO [wip] provide instance init by default in this "root" Makefile.

-include asc/env/current/default.mk
-include $(ASC_MAKE_INC)
