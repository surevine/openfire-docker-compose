#!/usr/local/bin/dumb-init /bin/bash
set -euo pipefail

# init configuration
[ -e "/data/security/keystore" ] || {
	mkdir -p /data/security
	mv /opt/openfire/resources/security/keystore /data/security/keystore
}

[ -d "/data/embedded-db" ] || { mkdir -p /data/embedded-db; }
[ -d "/data/conf" ] || { mv /opt/openfire/conf /data/conf; }

ln -sfn /data/security/keystore /opt/openfire/resources/security/keystore
ln -sfn /data/embedded-db /opt/openfire/embedded-db
rm -rf /opt/openfire/conf && ln -sfn /data/conf /opt/openfire/conf
ln -s /data/plugins/* /opt/openfire/plugins/

# start openfire
/opt/openfire/bin/openfire start

# let openfire start
echo "Waiting for Openfire to start..."
count=0
while [ ! -e /opt/openfire/logs/stdoutt.log ]; do
	if [ $count -eq 60 ]; then
		echo "Error starting Openfire. Exiting"
		exit 1
	fi
	count=$((count + 1))
	sleep 1
done

# tail the log
tail -F /opt/openfire/logs/*.log
