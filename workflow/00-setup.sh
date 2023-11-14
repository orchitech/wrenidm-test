#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "00-setup.sh..."

# Create managed user
MANAGED_USER_DATA='{
  "userName": "workflow",
  "givenName": "John",
  "sn": "Doe",
  "mail": "john.doe@wrensecurity.org",
  "password":"FooBar123"
}'
curl -si \
  -X PUT \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$MANAGED_USER_DATA" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/managed/user/workflow" \
| assert_response_status 201 \
> /dev/null

# Create managed role
MANAGED_ROLE_DATA='{
  "name": "employee",
  "description":"Role for employees."
}'
curl -si \
  -X PUT \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$MANAGED_ROLE_DATA" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/managed/role/employee" \
| assert_response_status 201 \
> /dev/null
