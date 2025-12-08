#!/bin/bash

PROJECT="openfire"
COMPOSE_FILE_COMMAND=("docker" "compose")
COMPOSE_FILE_COMMAND+=("--env-file" "../_common/.env")
COMPOSE_FILE_COMMAND+=("--project-name" "$PROJECT")


# Where is this script? It could be called from anywhere, so use this to get full paths.
SCRIPTPATH="$( cd "$(dirname "$0")"; pwd -P )"

source "$SCRIPTPATH/../_common/functions.sh"



echo "Starting a clustered environment."
COMPOSE_FILE_COMMAND+=("-f" "docker-compose-db.yml")

pushd "$SCRIPTPATH"

"$SCRIPTPATH"/../stop.sh
"${COMPOSE_FILE_COMMAND[@]}" pull --ignore-pull-failures

# Clean up temporary persistence data
if ! rm -rf _data; then
  echo "ERROR: Failed to delete the _data directory. Try with sudo, then re-run." && popd && exit 1
fi
mkdir _data
cp -r xmpp _data/
cp -r plugins _data/

"${COMPOSE_FILE_COMMAND[@]}" up -d || popd
popd