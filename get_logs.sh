#!/bin/bash
docker exec -t openfire-docker-compose_xmpp1_1 cat /usr/local/openfire/logs/all.log > 1all.log
docker exec -t openfire-docker-compose_xmpp2_1 cat /usr/local/openfire/logs/all.log > 2all.log