#!/bin/bash
docker exec -t openfire-docker-compose_xmpp1_1 cat /usr/local/openfire/logs/openfire.log > 1-openfire.log
docker exec -t openfire-docker-compose_xmpp2_1 cat /usr/local/openfire/logs/openfire.log > 2-openfire.log
docker exec -t openfire-docker-compose_xmpp3_1 cat /usr/local/openfire/logs/openfire.log > 3-openfire.log
docker exec -t openfire-docker-compose_otherxmpp_1 cat /usr/local/openfire/logs/openfire.log > other-openfire.log

#docker cp openfire-docker-compose_xmpp1_1:/usr/local/openfire/logs/all.log 1all.log
#docker cp openfire-docker-compose_xmpp2_1:/usr/local/openfire/logs/all.log 2all.log
