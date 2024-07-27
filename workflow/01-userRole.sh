#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "01-userRole.sh..."

# 1. Check user roles
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/managed/user/workflow/roles?_queryId=query-all-ids" \
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
  call_curl -si \
    -X POST \
    -H 'Content-Type: application/json' \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    -d "$WORKFLOW_DATA" \
    "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processinstance?_action=create" \
  | assert_response_status 201 \
  | get_response_body - \
  | jq -r "._id"
)

# 3. Check approval task
TASK_ID=$(
  call_curl -si \
    -X GET \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    "http://wrenidm.wrensecurity.local:8080/openidm/workflow/taskinstance?_queryId=filtered-query&processInstanceId=$WORKFLOW_ID&taskDefinitionKey=approval" \
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
call_curl -si \
  -X POST \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$APPROVAL_DATA" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/taskinstance/$TASK_ID?_action=complete" \
| assert_response_status \
| assert_response_body '."Task action performed" == "complete"' \
> /dev/null

# 5. Check workflow status
while true; do
  call_curl -si \
    -X GET \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processinstance/history/$WORKFLOW_ID" \
  | assert_response_status \
  | assert_response_body "._id == \"$WORKFLOW_ID\"" \
  | assert_response_body '.processVariables.decision == "approve"' \
  > /dev/null && break
  sleep 1
done

# 6. Check user roles
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/managed/user/workflow/roles?_queryFilter=true" \
| assert_response_status \
| assert_response_body '.resultCount == 1' \
| assert_response_body '.result[0]._ref == "managed/role/employee"' \
> /dev/null
