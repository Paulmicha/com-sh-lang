#!/usr/bin/env bash

##
# Unlogged parallel alias → thread/batch (`&` + wait).
#
# @example
#   make parallel e:transcribe-ogg e:transcribe-ocr
#   # Or :
#   asc/instance/parallel.sh e:transcribe-ogg e:transcribe-ocr
#

# This is just an alias for :
. asc/thread/batch.sh $@
