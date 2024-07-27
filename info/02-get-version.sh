#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "02-get-version.sh..."

call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/info/version" \
| assert_response_status \
| assert_response_body '.productVersion | test("^[\\d]+.[\\d]+.[\\d]+(-[A-Z][A-Z0-9-]*)?$")' \
> /dev/null
