#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "01-test.sh..."

call_curl -si \
  -X POST \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/system/ldap?_action=test" \
| assert_response_status \
| assert_response_body '.ok == true' \
> /dev/null
