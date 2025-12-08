#!/bin/bash
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
DB_HOST="db"

# 1. Wait for SQL Server
echo "Waiting for SQL Server to be ready..."
until $SQLCMD -S tcp:$DB_HOST,1433 -U sa -P "$SA_PASSWORD" -Q "SELECT 1" -C &> /dev/null
do
  echo -n "."
  sleep 1
done
echo "SQL Server is ready."

# 2. Check if DB exists. If NOT, Restore.
# We check sys.databases for 'openfire'
DB_EXISTS=$($SQLCMD -S tcp:$DB_HOST,1433 -U sa -P "$SA_PASSWORD" -Q "IF DB_ID('openfire') IS NOT NULL PRINT 'YES'" -C -h -1 | tr -d '[:space:]')

if [ "$DB_EXISTS" == "YES" ]; then
    echo "Database 'openfire' already exists. Skipping restore."
else
    echo "Restoring 'openfire' database from backup..."
    
    # RESTORE COMMAND
    # We use WITH REPLACE to overwrite any conflicts and ensure it loads.
    # Note: /init-scripts/ maps to your local ./sql folder via Docker Compose
    $SQLCMD -S tcp:$DB_HOST,1433 -U sa -P "$SA_PASSWORD" \
    -Q "RESTORE DATABASE [openfire] FROM DISK = '/init-scripts/openfire_initial.bak' WITH REPLACE" \
    -C
    
    echo "Restore completed."
fi