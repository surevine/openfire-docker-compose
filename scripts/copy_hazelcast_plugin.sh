#!/bin/bash
# For when you've built the hazelcast plugin locally and want this in your next stack
cp ../openfire-hazelcast-plugin/target/hazelcast-openfire-plugin-assembly.jar ./plugins_for_clustered/hazelcast.jar
cp ../openfire-hazelcast-plugin/target/hazelcast-openfire-plugin-assembly.jar ./plugins_for_federated/hazelcast.jar
cp ../openfire-hazelcast-plugin/target/hazelcast-openfire-plugin-assembly.jar ./plugins_for_other/hazelcast.jar
