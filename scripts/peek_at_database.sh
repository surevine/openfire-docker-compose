#!/bin/bash
# Get a dump of the Openfire database in db_1 to peek at
CONTAINER_NAME=$(docker ps --filter status=running --format "{{.Names}}" | grep -E openfire-docker.+db.1)
docker exec -t "$CONTAINER_NAME" pg_dump -U openfire openfire > peek.sql