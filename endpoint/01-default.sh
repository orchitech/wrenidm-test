#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "01-default.sh..."

curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/managed/user?_queryFilter=/userName+eq+\"endpoint\"" \
| assert_response_status \
| assert_response_body '.resultCount == 1' \
| assert_response_body '.result[0]._id == "endpoint"' \
> /dev/null
