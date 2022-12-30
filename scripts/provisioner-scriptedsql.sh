#!/bin/bash

set -e

curl -u openidm-admin:openidm-admin -XPOST 'localhost:8080/openidm/system/myScriptedConnector?_action=TESTs&_prettyPrint=true'
echo
