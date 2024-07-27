#!/bin/bash

. "$(dirname "${BASH_SOURCE[0]}")/../.common.sh"
. "$(dirname "${BASH_SOURCE[0]}")/../.client.sh"

log_message "03-endpoint.sh..."

# 1. Check process definitions

## Check query operation
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processdefinition?_queryId=filtered-query" \
| assert_response_status \
| assert_response_body '.resultCount == 2' \
| assert_response_body '.result[0].key | test("onboarding|userRole")' \
| assert_response_body '.result[1].key | test("onboarding|userRole")' \
> /dev/null

## Check read operation
ONBOARDING_DEFINITION_ID=$(
  call_curl -si \
    -X GET \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processdefinition?_queryId=filtered-query&key=onboarding" \
  | assert_response_status \
  | assert_response_body '.resultCount == 1' \
  | assert_response_body '.result[0].key == "onboarding"' \
  | get_response_body - \
  | jq -r ".result[0]._id"
)

## Check read operation for special fields
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processdefinition/$ONBOARDING_DEFINITION_ID?_fields=formProperties,formGenerationTemplate,diagram" \
| assert_response_status \
| assert_response_body '.formGenerationTemplate | test("^<div id=\"onboardingForm\"")' \
| assert_response_body '.diagram | test("^iVBORw")' \
| assert_response_body '.formProperties | length == 6' \
| assert_response_body '.formProperties | map(.name) | contains(["Username", "Workforce ID","Employee Type", "First Name", "Last Name", "Email Address"])' \
> /dev/null

# 2. Check task definitions

## Check query operation
ONBOARDING_APPROVAL_TASK_DEFINITION_ID=$(
  call_curl -si \
    -X GET \
    -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
    -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
    "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processdefinition/$ONBOARDING_DEFINITION_ID/taskdefinition?_queryId=query-all-ids" \
  | assert_response_status \
  | assert_response_body '.resultCount == 1' \
  | assert_response_body '.result[0]._id == "approval"' \
  | get_response_body - \
  | jq -r ".result[0]._id"
)

## Check read operation
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processdefinition/$ONBOARDING_DEFINITION_ID/taskdefinition/$ONBOARDING_APPROVAL_TASK_DEFINITION_ID" \
| assert_response_status \
| assert_response_body '.name == "approval"' \
| assert_response_body '.taskCandidateGroup | length == 1' \
| assert_response_body '.taskCandidateGroup[0] == "openidm-admin"' \
| assert_response_body '.formProperties.formPropertyHandlers | length == 1' \
| assert_response_body '.formProperties.formPropertyHandlers[0].name == "Decision"' \
> /dev/null

# 3. Check process instances

## Check create operation
WORKFLOW_DATA='{
  "_key": "onboarding",
  "userName": "onboarding-3",
  "workforceId": "654321",
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

## Check query operation
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processinstance?_queryId=filtered-query&processInstanceId=$WORKFLOW_ID" \
| assert_response_status \
| assert_response_body '.resultCount == 1' \
| assert_response_body ".result[0]._id == \"$WORKFLOW_ID\"" \
> /dev/null

## Check read operation
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processinstance/$WORKFLOW_ID" \
| assert_response_status \
| assert_response_body "._id == \"$WORKFLOW_ID\"" \
| assert_response_body '.processVariables.userName == "onboarding-3"' \
| assert_response_body '.tasks | length == 1' \
| assert_response_body '.tasks[0].name == "approval"' \
> /dev/null

## Check delete operation
call_curl -si \
  -X DELETE \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processinstance/$WORKFLOW_ID" \
| assert_response_status \
> /dev/null

call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processinstance/history/$WORKFLOW_ID" \
| assert_response_status \
| assert_response_body "._id == \"$WORKFLOW_ID\"" \
| assert_response_body '.deleteReason == "Deleted by Wren:IDM."' \
> /dev/null

# 4. Check task instances

## Check query operation
WORKFLOW_DATA='{
  "_key": "onboarding",
  "userName": "onboarding-4",
  "workforceId": "654321",
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

## Check read operation
call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/taskinstance/$TASK_ID" \
| assert_response_status \
| assert_response_body "._id == \"$TASK_ID\"" \
| assert_response_body '.assignee == null' \
| assert_response_body '.candidates.candidateGroups | length == 1' \
| assert_response_body '.candidates.candidateGroups[0] == "openidm-admin"' \
| assert_response_body '.variables.userName == "onboarding-4"' \
> /dev/null

## Check claim operation
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

## Check complete operation
COMPLETION_DATA='{
  "result": "reject"
}'
call_curl -si \
  -X POST \
  -H 'Content-Type: application/json' \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  -d "$COMPLETION_DATA" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/taskinstance/$TASK_ID?_action=complete" \
| assert_response_status \
| assert_response_body '."Task action performed" == "complete"' \
> /dev/null

call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/taskinstance/history?_queryId=filtered-query&processInstanceId=$WORKFLOW_ID&taskDefinitionKey=approval" \
| assert_response_status \
| assert_response_body '.resultCount == 1' \
| assert_response_body '.result[0].endTime != null' \
> /dev/null

call_curl -si \
  -X GET \
  -H "X-OpenIDM-Username: $ADMIN_USERNAME" \
  -H "X-OpenIDM-Password: $ADMIN_PASSWORD" \
  "http://wrenidm.wrensecurity.local:8080/openidm/workflow/processinstance/history/$WORKFLOW_ID" \
| assert_response_status \
| assert_response_body '.processVariables.decision == "reject"' \
| assert_response_body '.tasks[0].taskLocalVariables.result == "reject"' \
> /dev/null
