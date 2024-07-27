#!/bin/bash
#
# Common functions that can be sourced in test scripts.
#

set -eu -o pipefail

ADMIN_USERNAME=openidm-admin
ADMIN_PASSWORD=openidm-admin

trap "log_error Test failure!" ERR

log_message() {
  echo -e "\033[0;33m[TEST] $*\033[0m" >&2
}

log_error() {
  echo -e "\033[0;31m[ERROR] $*\033[0m" >&2
}

fail_test() {
  log_error "${1:-}"
  if [ -n "${2:-}" ]; then
    echo "$2" >&2
  fi
  exit 1
}

init_platform() {
  # Start required services
  docker compose up -d ldap smtp
  # Start Wren:IDM repository
  start_db
  # Start Wren:IDM
  start_idm
}

shutdown_platform() {
  docker compose down -v
}

start_idm() {
  log_message "Starting Wren:IDM test instance..."
  docker compose up -d wrenidm
  while true; do
    check_idm && break
    log_message "Waiting for the container to startup..."
    sleep 2
  done
  log_message "Wren:IDM test instance started..."
}

check_idm() {
  local status
  status=$(exec_idm curl -s -u $ADMIN_USERNAME:$ADMIN_USERNAME http://localhost:8080/openidm/info/ping)
  [ $? -eq 0 ] || return 1
  $(echo "$status" | grep "\"state\":\"ACTIVE_READY\"" > /dev/null)
}

stop_idm() {
  log_message "Stopping Wren:IDM test instance..."
  docker compose rm -fs wrenidm
  log_message "Wren:IDM test instance succesfuly stopped..."
}

exec_idm() {
  docker compose exec -T wrenidm "$@"
}

start_db() {
  log_message "Starting H2 test instance..."
  docker compose up -d h2
  while true; do
    check_db && break
    log_message "Waiting for the container to startup..."
    sleep 1
  done
  log_message "H2 test instance started."
}

check_db() {
  local response=$(exec_db java -cp /h2/h2.jar org.h2.tools.Shell -url jdbc:h2:tcp://h2/~/wrenidm -user wrenidm -password wrenidm -sql "SELECT 'H2 Database Started'")
  $(echo $response | grep "H2 Database Started" > /dev/null) || return 1
}

exec_db() {
  docker exec -i wrenidm-test-db "$@"
}

exec_ldap() {
  docker exec -i wrenidm-test-ldap "$@" < /dev/stdin
}
