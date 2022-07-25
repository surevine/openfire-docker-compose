#!/bin/bash

NODE=$1
CONTAINER_NAME=pumba_node"$NODE"

[[ $(docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}') == "$CONTAINER_NAME" ]] \
    && CONTAINER_EXISTS=1 || CONTAINER_EXISTS=0

if [ $CONTAINER_EXISTS == 1 ]; then
    docker stop "$CONTAINER_NAME"
else
    echo "No container to remove. Are you sure this node was blocked?"
fi
