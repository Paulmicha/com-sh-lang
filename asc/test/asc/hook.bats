#!/usr/bin/env bats

@test "Single action hook" {
  exit_code="$(asc/test/asc/hook.sh 'Single action hook')"
  [ -e $exit_code ]
}
