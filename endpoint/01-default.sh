#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "01-default.sh..."

call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/managed/user?_queryFilter=/userName+eq+\"endpoint\"" \
| assert_response_status \
| assert_response_body '.resultCount == 1' \
| assert_response_body '.result[0]._id == "endpoint"' \
> /dev/null
