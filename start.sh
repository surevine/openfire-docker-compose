#!/bin/bash

usage() { echo "Usage: $0 [-c] [-n openfire-tag] [-h]

  -c               Launches a Cluster instead of a FMUC stack
  -n openfire-tag  Launches all Openfire instances with the specified tag. This overrides the value in .env
  -h               Show this helpful information
"; exit 0; }

CLUSTER_MODE=false
COMPOSE_FILE_COMMAND=("docker-compose")

while getopts cn:h o; do
  case "$o" in
    c)
        CLUSTER_MODE=true
        ;;
    n)
        echo "Using Openfire tag: $1"
        export OPENFIRE_TAG=$1
        ;;
    h)  
        usage
        ;;
    *)
        usage
        ;;
  esac
done

case $CLUSTER_MODE in
  (true)   echo "Starting a clustered environment."
           COMPOSE_FILE_COMMAND+=("-f" "docker-compose-clustered.yml");;
  (false)  echo "Starting a federated environment (use -c to start a clustered environment instead)."
           COMPOSE_FILE_COMMAND+=("-f" "docker-compose-federated.yml");;
esac

"${COMPOSE_FILE_COMMAND[@]}" down
"${COMPOSE_FILE_COMMAND[@]}" pull

# Clean up temporary persistence data
rm -rf _data
mkdir _data
cp -r xmpp _data/
cp -r plugins _data/

"${COMPOSE_FILE_COMMAND[@]}" up