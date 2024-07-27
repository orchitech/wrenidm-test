#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "00-setup.sh..."

# Create testing managed user
MANAGED_USER_DATA='{
  "userName": "endpoint",
  "givenName": "John",
  "sn": "Doe",
  "mail": "doe@wrensecurity.org",
  "password":"Password1"
}'
call_curl -si \
  -X PUT \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$MANAGED_USER_DATA" \
  "http://wrenidm.wrensecurity.local:8080/openidm/managed/user/endpoint" \
| assert_response_status 201 \
> /dev/null
