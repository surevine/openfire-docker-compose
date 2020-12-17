#!/bin/bash
#For when you've built the monitoring plugin locally and want this in your next stack
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./xmpp/clustered/1/plugins/monitoring.jar
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./xmpp/clustered/2/plugins/monitoring.jar
