#!/bin/bash

# A list of all possible docker compose files that might've been used to start the stack

docker-compose \
 -f docker-compose-clustered.yml \
 -f docker-compose-federated.yml \
 -f docker-compose-otherdomain.yml \
 -f docker-compose-logging.yml \
down