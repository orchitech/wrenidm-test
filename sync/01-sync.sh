#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "01-sync.sh..."

# 1. Trigger reconciliation for 'csvEmployee_managedUser' mapping
RECONID=$(
  curl -si \
    -X POST \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
    "http://wrenidm.wrensecurity.local/openidm/recon?_action=recon&mapping=csvEmployee_managedUser&waitForCompletion=true" \
  | assert_response_status \
  | assert_response_body '.state == "SUCCESS"' \
  | get_response_body - \
  | jq -r "._id"
)

# 2. Check reconciliation result
curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/recon/$RECONID" \
| assert_response_status \
| assert_response_body '.situationSummary.ABSENT == 1' \
| assert_response_body '.situationSummary.FOUND == 1' \
| assert_response_body '.situationSummary.SOURCE_IGNORED == 1' \
> /dev/null

# 3. Check managed users in Wren:IDM
curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/managed/user?_queryFilter=/userName+sw+\"sync\"" \
| assert_response_status \
| assert_response_body '.resultCount == 2' \
| assert_response_body '.result[0]._id | test("^sync(1|2)$")' \
| assert_response_body '.result[1]._id | test("^sync(1|2)$")' \
> /dev/null

# 4. Check implicit synchronization
while true; do
  curl -si \
    -X GET \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
    "http://wrenidm.wrensecurity.local/openidm/audit/sync?_queryFilter=/mapping+eq+\"managedUser_ldapAccount\"+and+/sourceObjectId+sw+\"managed/user/sync\"+and+/status+eq+\"SUCCESS\"" \
  | assert_response_status \
  | assert_response_body '.resultCount == 2' \
  > /dev/null && break
  sleep 1
done

# 5. Check accounts in LDAP
curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/system/ldap/account?_queryId=query-all-ids" \
| assert_response_status \
| assert_response_body '.resultCount == 2' \
| assert_response_body '.result[0]._id | test("^uid=sync(1|2),dc=wrensecurity,dc=org$")' \
| assert_response_body '.result[1]._id | test("^uid=sync(1|2),dc=wrensecurity,dc=org$")' \
> /dev/null
