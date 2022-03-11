#!/bin/bash
# For when you've built the monitoring plugin locally and want this in your next stack
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./cluster/plugins/monitoring.jar
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./cluster_with_federation/plugins/monitoring.jar
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./cluster_with_federation/plugins_for_other/monitoring.jar
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./federation/plugins/monitoring.jar
