#!/bin/bash

#set -euo pipefail

mkdir -p /tmp/openfiredb
DEFAULT_OPENFIRE_DB_TAG="v3.9.3"

DBURL_MODERN="https://raw.githubusercontent.com/igniterealtime/Openfire/$OPENFIRE_DB_TAG/distribution/src/database/openfire_sqlserver.sql"
DBURL_LEGACY="https://raw.githubusercontent.com/igniterealtime/Openfire/$OPENFIRE_DB_TAG/src/database/openfire_sqlserver.sql"

urlexists(){
    wget --quiet --spider $1
}

if urlexists "$DBURL_MODERN"; then
    DBURL=$DBURL_MODERN
elif urlexists "$DBURL_MODERN"; then
    DBURL=$DBURL_LEGACY
else
    echo "Could not find the bootstrap databse for the specified tag: $OPENFIRE_DB_TAG. Reverting to using tag: $DEFAULT_OPENFIRE_DB_TAG"
    DBURL="https://raw.githubusercontent.com/igniterealtime/Openfire/$DEFAULT_OPENFIRE_DB_TAG/src/database/openfire_sqlserver.sql"
fi
echo "Downloading Openfire bootstrap database from $DBURL"
wget --quiet $DBURL --output-document=/tmp/openfiredb/openfire_sqlserver.sql

/opt/mssql/bin/sqlservr & #Start SQL Server`
/scripts/wait-for-it.sh -t 30 127.0.0.1:1433

for i in {1..50};
do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d master -Q "CREATE DATABASE openfire;"
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d openfire -i /tmp/openfiredb/openfire_sqlserver.sql
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d openfire -i /tmp/openfiredb/openfire_data.sql
    if [ $? -eq 0 ]
    then
        echo "Openfire data imported to SQL Server"
        break
    else
        echo "not ready yet..."
        sleep 1
    fi
done

sleep infinity # Keep the container running forever
