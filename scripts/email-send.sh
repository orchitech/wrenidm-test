#!/bin/bash

set -e

read -r -d '' MAIL_BODY <<'END' || :
{
  "from": "source@example.com",
  "to": "target@example.com",
  "subject": "TEST NOTIFICATION",
  "type": "text/html",
  "body": "<b>HELLO</b> <i>WORLD</i>"
}  
END

curl -u openidm-admin:openidm-admin -XPOST -H 'Content-Type: application/json' localhost:8080/openidm/external/email?_action=send -d "$MAIL_BODY"
