#!/bin/bash
docker exec -t openfire-docker-compose-xmpp1-1 cat /usr/local/openfire/logs/openfire.log > 1-openfire.log
docker exec -t openfire-docker-compose-xmpp2-1 cat /usr/local/openfire/logs/openfire.log > 2-openfire.log
docker exec -t openfire-docker-compose-xmpp3-1 cat /usr/local/openfire/logs/openfire.log > 3-openfire.log
docker exec -t openfire-docker-compose_otherxmpp_1 cat /usr/local/openfire/logs/openfire.log > other-openfire.log
