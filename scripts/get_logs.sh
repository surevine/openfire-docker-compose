#!/bin/bash
docker exec -t openfire-docker-compose_xmpp1_1 cat /usr/local/openfire/logs/all.log > 1all.log
docker exec -t openfire-docker-compose_xmpp2_1 cat /usr/local/openfire/logs/all.log > 2all.log
docker exec -t openfire-docker-compose_xmpp2_1 cat /usr/local/openfire/logs/jive.audit-20210202-000.log > jiveaudit.log

#docker cp openfire-docker-compose_xmpp1_1:/usr/local/openfire/logs/all.log 1all.log
#docker cp openfire-docker-compose_xmpp2_1:/usr/local/openfire/logs/all.log 2all.log
