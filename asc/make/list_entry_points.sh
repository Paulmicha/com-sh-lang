#!/usr/bin/env bash

##
# List all currently active make entry points.
#
# @see Makefile
# @see asc/make/default.mk
#
# @example
#   make list-entry-points
#   # Or :
#   asc/make/list_entry_points.sh
#

. asc/bootstrap.sh

mk_tasks=()
mk_entry_points=()
output=()

u_make_list_entry_points

for index in "${!mk_entry_points[@]}"; do
  task="${mk_tasks[index]}"
  script="${mk_entry_points[index]}"

  output+=("$task
  → $script")
done

u_array_qsort "${output[@]}"

for line in "${sorted_arr[@]}"; do
  echo "$line"
done
