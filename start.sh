#!/bin/bash

usage() { echo "Usage: $0 [-c] [-o] [-l] [-n openfire-tag] [-h]

  -c               Launches a Cluster instead of a FMUC stack
  -o               Launches another separate domain alongside the cluster
  -l               Launches a Dozzle container to collect logs
  -n openfire-tag  Launches all Openfire instances with the specified tag. This overrides the value in .env
  -h               Show this helpful information
"; exit 0; }

CLUSTER_MODE=false
OTHER_DOMAIN=false
DOZZLE=false
COMPOSE_FILE_COMMAND=("docker-compose")

while getopts coln:h o; do
  case "$o" in
    c)
        CLUSTER_MODE=true
        ;;
    o)
        OTHER_DOMAIN=true
        ;;
    l)
        DOZZLE=true
        ;;
    n)
        if [[ $OPTARG =~ " " ]]; then
          echo "Docker tags cannot contain spaces"
          exit 1
        fi
        echo "Using Openfire tag: $OPTARG"
        export OPENFIRE_TAG="$OPTARG"
        ;;
    h)  
        usage
        ;;
    *)
        usage
        ;;
  esac
done

if [ $OTHER_DOMAIN == "true" ]; then 
  if [ $CLUSTER_MODE == "false" ]; then
    echo "Other domains are only supported alongside clusters"
    exit 1
  else
    COMPOSE_FILE_COMMAND+=("-f" "docker-compose-otherdomain.yml")
  fi
fi

case $CLUSTER_MODE in
  (true)   echo "Starting a clustered environment."
           COMPOSE_FILE_COMMAND+=("-f" "docker-compose-clustered.yml");;
  (false)  echo "Starting a federated environment (use -c to start a clustered environment instead)."
           COMPOSE_FILE_COMMAND+=("-f" "docker-compose-federated.yml");;
esac

if [ $DOZZLE == "true" ]; then
  COMPOSE_FILE_COMMAND+=("-f" "docker-compose-logging.yml")
fi

"${COMPOSE_FILE_COMMAND[@]}" down
"${COMPOSE_FILE_COMMAND[@]}" pull

# Clean up temporary persistence data
rm -rf _data
mkdir _data
cp -r xmpp _data/
cp -r plugins_for_clustered _data/
cp -r plugins_for_federated _data/
cp -r plugins_for_other _data/

"${COMPOSE_FILE_COMMAND[@]}" up -d