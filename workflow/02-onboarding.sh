#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "02-onboarding.sh..."

# 1. Create onboarding workflow
WORKFLOW_DATA='{
  "_key": "onboarding",
  "userName": "onboarding",
  "workforceId": "123456",
  "employeeType": "INTERNAL",
  "givenName": "John",
  "sn": "Doe",
  "mail": "john.doe@wrensecurity.org"
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

# 2. Get approval task
TASK_ID=$(
  call_curl -si \
    -X GET \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    "http://wrenidm.wrensecurity.local:8080/openidm/workflow/taskinstance?_queryId=filtered-query&processInstanceId=$WORKFLOW_ID&taskDefinitionKey=approval" \
  | assert_response_status \
  | assert_response_body '.resultCount == 1' \
  | assert_response_body ".result[0].processInstanceId == \"$WORKFLOW_ID\"" \
  | get_response_body - \
  | jq -r ".result[0]._id"
)

# 3. Claim task
CLAIM_DATA='{
  "userId": "openidm-admin"
}'
call_curl -si \
  -X POST \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$CLAIM_DATA" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/taskinstance/$TASK_ID?_action=claim" \
| assert_response_status \
| assert_response_body '."Task action performed" == "claim"' \
> /dev/null

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

# 6. Check created user
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/managed/user/onboarding" \
| assert_response_status \
| assert_response_body '._id == "onboarding"' \
> /dev/null
