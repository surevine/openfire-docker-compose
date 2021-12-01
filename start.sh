#!/bin/bash

usage() { echo "Usage: $0 [-c] [-o] [-l] [-f] [-n openfire-tag] [-h]

  -c               Launches a Cluster instead of a FMUC stack
  -o               Launches another separate domain alongside the cluster
  -l               Launches a Dozzle container to collect logs
  -f               Ignore errors, like file cleanups. Don't pause for the user, and just keep going.
  -n openfire-tag  Launches all Openfire instances with the specified tag. This overrides the value in .env
  -h               Show this helpful information
"; exit 0; }

CLUSTER_MODE=false
OTHER_DOMAIN=false
DOZZLE=false
COMPOSE_FILE_COMMAND=("docker-compose")
NO_SUDO=false

while getopts colfn:h o; do
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
    f)
        NO_SUDO=true
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
sudo_for_cleanup() {
  echo "Couldn't clean up the _data directory, probably due to permissions on files that a container created"
  if [ $NO_SUDO == "false" ]; then
    echo "Trying sudo to tidy it up"
    sudo rm -rf _data
  fi
}

rm -rf _data || sudo_for_cleanup
mkdir _data
cp -r xmpp _data/
cp -r plugins_for_clustered _data/
cp -r plugins_for_federated _data/
cp -r plugins_for_other _data/

"${COMPOSE_FILE_COMMAND[@]}" up -d