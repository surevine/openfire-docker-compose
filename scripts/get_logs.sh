#!/bin/bash
CONTAINER_ONE=$(docker ps --filter status=running --format "{{.Names}}" | grep -E openfire-docker.+xmpp1.1)
CONTAINER_TWO=$(docker ps --filter status=running --format "{{.Names}}" | grep -E openfire-docker.+xmpp2.1)
CONTAINER_THREE=$(docker ps --filter status=running --format "{{.Names}}" | grep -E openfire-docker.+xmpp3.1)
CONTAINER_OTHER=$(docker ps --filter status=running --format "{{.Names}}" | grep -E openfire-docker.+otherxmpp.1)

[ -n "$CONTAINER_ONE" ] && docker exec -t "$CONTAINER_ONE" cat /usr/local/openfire/logs/openfire.log > 1-openfire.log
[ -n "$CONTAINER_TWO" ] && docker exec -t "$CONTAINER_TWO" cat /usr/local/openfire/logs/openfire.log > 2-openfire.log
[ -n "$CONTAINER_THREE" ] && docker exec -t "$CONTAINER_THREE" cat /usr/local/openfire/logs/openfire.log > 3-openfire.log
[ -n "$CONTAINER_OTHER" ] && docker exec -t "$CONTAINER_OTHER" cat /usr/local/openfire/logs/openfire.log > other-openfire.log
