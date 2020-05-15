#!/bin/sh
docker-compose down
docker-compose pull
rm -rf _data
mkdir _data
cp -r xmpp _data/
docker-compose up