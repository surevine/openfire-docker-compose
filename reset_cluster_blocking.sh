#!/bin/bash

stop_if_exists(){
    CONTAINER_NAME=$1
    [[ $(docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}') == "$CONTAINER_NAME" ]] && docker stop "$CONTAINER_NAME"
}

stop_if_exists "pumba_node1"
stop_if_exists "pumba_node2"
stop_if_exists "pumba_node3"

exit 0