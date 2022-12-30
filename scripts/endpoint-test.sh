#!/bin/bash

set -e

curl -u openidm-admin:openidm-admin 'localhost:8080/openidm/endpoint/foo'
echo

curl -u openidm-admin:openidm-admin 'localhost:8080/openidm/endpoint/demo'
echo
