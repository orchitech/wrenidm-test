#!/bin/bash

set -e

curl -u openidm-admin:openidm-admin -XPOST 'localhost:8080/openidm/system/openldap?_action=TEST&_prettyPrint=true'
echo

curl -u openidm-admin:openidm-admin 'localhost:8080/openidm/system/openldap/account?_queryFilter=true&_prettyPrint=true'
echo
