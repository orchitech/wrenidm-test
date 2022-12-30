#!/bin/bash

java -cp /h2/h2.jar org.h2.tools.RunScript -url "jdbc:h2:~/openidm" -user openidm -password openidm -script /h2/openidm.sql

exec java -co /h2/h2.jar org.h2.tools.Server -web -webAllowOthers -tcp -tcpAllowOthers
