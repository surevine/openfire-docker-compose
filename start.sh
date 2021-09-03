#!/bin/sh

COMPOSE_FILE=docker-compose-federated.yml

if [ "$1" = "-c" ]; then
  echo "Starting a clustered environment."
  COMPOSE_FILE=docker-compose-clustered.yml
  shift
else
  echo "Starting a federated environment (use -c to start a clustered environment instead)."
fi

docker-compose -f $COMPOSE_FILE down
docker-compose -f $COMPOSE_FILE pull

# Clean up temporary persistence data
rm -rf _data
mkdir _data
cp -r xmpp _data/
cp -r plugins _data/

if [ -n "$1" ]; then
  echo "Using Openfire tag: $1"
  export OPENFIRE_TAG=$1
fi
docker-compose -f $COMPOSE_FILE up