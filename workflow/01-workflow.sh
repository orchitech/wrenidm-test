#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "01-workflow.sh..."

# 1. Check user roles
curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/managed/user/workflow/roles?_queryId=query-all-ids" \
| assert_response_status \
| assert_response_body '.resultCount == 0' \
> /dev/null

# 2. Create user-role assignment workflow
WORKFLOW_DATA='{
  "_key": "userRole",
  "userId": "managed/user/workflow",
  "roleId": "managed/role/employee"
}'
WORKFLOW_ID=$(
  curl -si \
    -X POST \
    -H 'Content-Type: application/json' \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
    -d "$WORKFLOW_DATA" \
    "http://wrenidm.wrensecurity.local/openidm/workflow/processinstance?_action=create" \
  | assert_response_status 201 \
  | get_response_body - \
  | jq -r "._id"
)

# 3. Check approval task
TASK_ID=$(
  curl -si \
    -X GET \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
    "http://wrenidm.wrensecurity.local/openidm/workflow/taskinstance?_queryId=query-all-ids" \
  | assert_response_status \
  | assert_response_body '.resultCount == 1' \
  | assert_response_body ".result[0].processInstanceId == \"$WORKFLOW_ID\"" \
  | assert_response_body ".result[0].assignee == \"$ADMIN_USERNAME\"" \
  | get_response_body - \
  | jq -r ".result[0]._id"
)

# 4. Approve task
APPROVAL_DATA='{
  "result": "approve"
}'
curl -si \
  -X POST \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$APPROVAL_DATA" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/workflow/taskinstance/$TASK_ID?_action=complete" \
| assert_response_status \
| assert_response_body '."Task action performed" == "complete"' \
> /dev/null

# 5. Check user roles
curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  --connect-to "wrenidm.wrensecurity.local:80:10.0.0.11:8080" \
  "http://wrenidm.wrensecurity.local/openidm/managed/user/workflow/roles?_queryFilter=true" \
| assert_response_status \
| assert_response_body '.resultCount == 1' \
| assert_response_body '.result[0]._ref == "managed/role/employee"' \
> /dev/null
