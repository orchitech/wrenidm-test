#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "01-send-email.sh..."

EMAIL_DATA='{
  "type": "text/html",
  "from": "idm@wrensecurity.org",
  "to": "foobar@wrensecurity.org",
  "subject": "Test subject",
  "body": "Test body"
}'

# 1. Send Email
call_curl -si \
  -X POST \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$EMAIL_DATA" \
  "http://wrenidm.wrensecurity.local:8080/openidm/external/email?_action=send" \
| assert_response_status \
| assert_response_body '.status == "OK"' \
> /dev/null

# 2. Check mail inbox
call_curl -si \
  -X GET \
  "http://smtp.wrensecurity.local:8025/api/v2/messages" \
| assert_response_status \
| assert_response_body '.total == 1' \
| assert_response_body '.items[0].Content.Headers."Content-Type"[0] | test("text/html")' \
| assert_response_body ".items[0].Content.Headers.From[0] == $(echo $EMAIL_DATA | jq '.from')" \
| assert_response_body ".items[0].Content.Headers.To[0] == $(echo $EMAIL_DATA | jq '.to')" \
| assert_response_body ".items[0].Content.Headers.Subject[0] == $(echo $EMAIL_DATA | jq '.subject')" \
| assert_response_body ".items[0].Content.Body == $(echo $EMAIL_DATA | jq '.body')" \
> /dev/null
