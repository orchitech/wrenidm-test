import groovy.sql.Sql;
import org.identityconnectors.common.logging.Log;

import java.sql.Connection;
// Parameters:
// The connector sends the following:
// connection: handler to the SQL connection
// action: a string describing the action ("TEST" here)
// log: a handler to the Log facility

def sql = new Sql(connection as Connection);
def log = log as Log;

log.info("Entering Test Script");

// a relatively-cheap query to run on start up to ensure database connectivity and table existence
sql.eachRow("select * from openidm.auditauthentication limit 1", { } );
sql.eachRow("select * from openidm.auditrecon limit 1", { } );
sql.eachRow("select * from openidm.auditactivity limit 1", { } );
sql.eachRow("select * from openidm.auditaccess limit 1", { } );
sql.eachRow("select * from openidm.auditsync limit 1", { } );

