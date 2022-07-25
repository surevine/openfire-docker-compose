#!/bin/bash

CONTAINER_TO_REMOVE=$(docker ps --filter status=running --format "{{.Names}}" | grep -E openfire.+xmpp2.1)
CONTAINER_NAME=pumba_node2

echo "About to be blocked from communication: $CONTAINER_TO_REMOVE"

docker run -d --rm \
    --name "$CONTAINER_NAME" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gaiaadm/pumba netem --tc-image fishbowler/iproute2 --target 172.50.0.10 --target 172.50.0.20 \
    --duration 24h \
    loss --percent 100 \
    "$CONTAINER_TO_REMOVE"

sleep 1

[[ $(docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}') == "$CONTAINER_NAME" ]] || (echo "Failed to block traffic. The environment likely needs restarting" && exit 1)
