#!/bin/bash

#Parameter NODE is the ID of the node you wish to drop from the cluster
#Example usage: `./remove_node_from_cluster.sh 1` to remove node xmpp1

NODE=$1
CONTAINER_TO_REMOVE=$(docker ps --filter status=running --format "{{.Names}}" | grep -E openfire.+xmpp"$NODE".1)
CONTAINER_NAME=pumba_node"$NODE"

echo "About to be removed from cluster: $CONTAINER_TO_REMOVE"

docker run -d --rm \
    --name "$CONTAINER_NAME" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gaiaadm/pumba netem --tc-image fishbowler/iproute2 --target 172.60.0.10 --target 172.60.0.20 --target 172.60.0.30 \
    --duration 24h \
    loss --percent 100 \
    "$CONTAINER_TO_REMOVE"

sleep 1

[[ $(docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}') == "$CONTAINER_NAME" ]] || (echo "Failed to block traffic. The cluster likely needs restarting" && exit 1)
