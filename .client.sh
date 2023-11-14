#!/bin/bash

#
# Get response body from request passed through stdin or as a function argument.
#
get_response_body() {
  local input=${1:-}
  if [ "$input" = "-" ]; then
    input=$(cat)
  fi
  echo -n "$input" | sed -r '0,/^[\r\n]+/d'
}

#
# Get response status code from request passed through stdin or as a function argument.
#
get_response_status() {
  local input=${1:-}
  if [ "$input" = "-" ]; then
    input=$(cat)
  fi
  echo -n "$input" | head -n 1 | cut -d' ' -f2
}

#
# Assert response status code value.
#
assert_response_status() {
  local expected_status=${1:-200}

  local response=$(cat)
  local response_status=$(get_response_status "$response")

  [ "$response_status" -eq "$expected_status" ] || fail_test "Invalid response code" "$response"
  echo -n "$response"
}

#
# Assert JSON response body content.
#
# Usage: assert_response_body <jq_expression>
#
assert_response_body() {
  local expression="$1"

  local response=$(cat)
  local response_body=$(get_response_body "$response")

  [ -n "$response_body" ] || fail_test "Unable to test empty response with: $expression"

  echo -n "$response_body" | jq -e "$expression" > /dev/null \
    || fail_test "Failed matching response with: $expression" "$response_body"

  echo -n "$response"
}
