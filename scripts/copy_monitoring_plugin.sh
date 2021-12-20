#!/bin/bash
# For when you've built the monitoring plugin locally and want this in your next stack
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./plugins_for_clustered/monitoring.jar
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./plugins_for_federated/monitoring.jar
cp ../openfire-monitoring-plugin/target/monitoring-openfire-plugin-assembly.jar ./plugins_for_other/monitoring.jar
