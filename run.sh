#!/bin/bash
#
# Simple script for running full test suite.
#

. "$(dirname "${BASH_SOURCE[0]}")/.common.sh"

# Hardcoded list of test categories
TEST_CATEGORIES=(
  "email"
  "endpoint"
  "info"
  "provisioner"
  "sync"
  "workflow"
)

log_suite() {
  echo -e "\033[1;36m[SUITE] $1\033[0m" >&2
}

run_tests() {
  local category="$1"
  log_suite "Running '$category' tests"
  run-parts --regex '^[^\.].*.sh$' --exit-on-error "$category" -v
}

run_suite() {
  local skip=${RESUME_FROM:-}
  for category in ${TEST_CATEGORIES[@]}; do
    if [ "$category" = "$skip" ]; then
      skip=
    fi
    if [ ! -z "$skip" ]; then
      continue
    fi
    if ! run_tests "$category"; then
      return 1
    fi
  done
  log_suite "Finished running tests"
}

init_platform
run_suite
shutdown_platform
