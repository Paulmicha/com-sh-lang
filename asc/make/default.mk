
##
# Default ASC tasks.
#
# Uses a "call wrap" script as an entry point to any other ASC script.
#
# @see asc/make/call_wrap.make.sh
#
# It forwards escaped arguments to maintain the possibility to use values (in
# single quotes) with space, $, ", etc.
#
# Like :
# $ make drush ev '$test = "Hello Drupal php"; print $test;'
#
# By default, ASC provides the following tasks for all project instances :
# - [default] 'init': the 1st common step necessary to actually make ASC & its
#   extensions useful;
# - 'hook', a convenience wrapper to ASC hook() calls;
# - 'hook-debug', the same except it will just print out the lookup paths.
#   Useful for looking up positive matches to then provide overrides and/or
#   complements;
# - 'globals-lp', to show every globals lookup paths checked for aggregation
#   during instance init for current project instance;
# - 'self-test', to execute a few tests locally.
#
# @example
#   # Initialize current project instance = trigger "instance init" :
#   make
#   make init # <- Alternative call (the 'init' task is the default).
#
#   # Print lookup paths used for globals aggregation during instance init.
#   make globals-lp
#
#   # Print lookup paths for the ASC hook call :
#   # hook -s 'instance' -a 'stop' -v 'PROVISION_USING HOST_TYPE'
#   make hook-debug s:instance a:stop v:PROVISION_USING HOST_TYPE
#
#   # Print result of the "most specific" hook call variant :
#   make hook-debug ms s:instance a:stop v:PROVISION_USING HOST_TYPE
#
#   # Trigger "instance start" manually :
#   make hook s:instance a:start
#
#   # Print lookup paths for "instance start" using PROVISION_USING variant :
#   make hook-debug s:instance a:start v:PROVISION_USING
#   # Same but using more variants :
#   make hook-debug s:instance a:start v:PROVISION_USING HOST_TYPE INSTANCE_TYPE
#
#   # Trigger "test self_test" manually :
#   make self-test
#

.PHONY: init init-debug setup hook hook-debug globals-lp self-test debug
# .PHONY: init init-debug reinit setup hook hook-debug globals-lp self-test debug

init:
	@ asc/make/call_wrap.make.sh asc/instance/init.sh $(MAKECMDGOALS)

init-debug:
	@ asc/make/call_wrap.make.sh asc/instance/init.sh -d -r $(MAKECMDGOALS)

# TODO [evol] is this really overridden by scripts/asc/local/generated.mk ?
# reinit:
# 	@ asc/make/call_wrap.make.sh asc/instance/reinit.sh $(MAKECMDGOALS)

setup:
	@ asc/make/call_wrap.make.sh asc/instance/setup.sh $(MAKECMDGOALS)

hook:
	@ asc/make/call_wrap.make.sh asc/instance/hook.make.sh $(MAKECMDGOALS)

hook-debug:
	@ asc/make/call_wrap.make.sh asc/instance/hook.make.sh -d -t $(MAKECMDGOALS)

globals-lp:
	@ asc/make/call_wrap.make.sh asc/env/global_lookup_paths.make.sh $(MAKECMDGOALS)

self-test:
	@ asc/make/call_wrap.make.sh asc/test/self_test.sh $(MAKECMDGOALS)

debug:
	@ echo "debug MAKECMDGOALS (unescaped, wrapped in single quotes) = '$(MAKECMDGOALS)'";
	@ asc/make/call_wrap.make.sh asc/make/echo.make.sh $(MAKECMDGOALS)
