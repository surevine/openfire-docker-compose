#!/bin/bash
# Get a dump of the Openfire database in db_1 to peek at
docker ps --filter status=running --format "{{.Names}}" | grep -E openfire.+db | \
  awk '{ system("docker exec -t "$1" pg_dump -U openfire openfire > peek_"$1".sql") }'
