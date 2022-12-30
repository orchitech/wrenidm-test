#!/bin/bash

set -e

curl -u openidm-admin:openidm-admin 'localhost:8080/openidm/info/version'
echo
