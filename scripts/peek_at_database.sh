#!/bin/bash
# Get a dump of the Openfire database in db_1 to peek at
docker exec -t openfire-docker-compose_db_1 pg_dump -U openfire openfire > peek.sql