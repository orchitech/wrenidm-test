#!/bin/bash

set -e

curl -u openidm-admin:openidm-admin 'localhost:8080/openidm/managed/user?_queryId=query-all-ids&_prettyPrint=true'
