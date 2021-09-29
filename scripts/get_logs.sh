#!/bin/bash
docker exec -t openfire-docker-compose_xmpp1_1 cat /usr/local/openfire/logs/all.log > 1-all.log
docker exec -t openfire-docker-compose_xmpp2_1 cat /usr/local/openfire/logs/all.log > 2-all.log
docker exec -t openfire-docker-compose_xmpp3_1 cat /usr/local/openfire/logs/all.log > 3-all.log
docker exec -t openfire-docker-compose_xmpp2_1 cat /usr/local/openfire/logs/jive.audit-20210202-000.log > 2-jiveaudit.log
docker exec -t openfire-docker-compose_otherxmpp_1 cat /usr/local/openfire/logs/all.log > other-all.log

#docker cp openfire-docker-compose_xmpp1_1:/usr/local/openfire/logs/all.log 1all.log
#docker cp openfire-docker-compose_xmpp2_1:/usr/local/openfire/logs/all.log 2all.log
