#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "00-setup.sh..."

# Create testing managed user
MANAGED_USER_DATA='{
  "userName": "sync2",
  "givenName": "John",
  "sn": "Doe",
  "mail": "john.doe@wrensecurity.org",
  "telephoneNumber": "5554567",
  "password":"FooBar123"
}'
call_curl -si \
  -X PUT \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$MANAGED_USER_DATA" \
  "http://wrenidm.wrensecurity.local:8080/openidm/managed/user/sync2" \
| assert_response_status 201 \
> /dev/null
