# Clustered configuration

Running `./start.sh` will perform some cleanup then start the containers in a clustered configuration.
When running, the system looks like this:

```
                   +--------------------------------------------------+
                   |           172.60.0.99                            |
                   |       +----------------+                         |
                   |       |                |+--------------+         |
(XMPP-C2S)  55222 -|-------|  Load Balancer |+-------+      |         |
(BOSH)      57070 -|       |                |        |      |         |
(BOSHS)     57443 -|       +----------------+        |      |         |
                   |           |                     |  172.60.0.30   |
                   |           |                     |  +--------+    |
                   |           |          +=============+        |    |- 5223 (XMPP-C2S)
                   |           |          |          |  | XMPP 3 |----|- 5263 (XMPP-S2S)
                   |           |          |          |  |        |    |- 9093 (HTTP-Admin)
                   |           |          |          |  +------+-+    |- 7073 (BOSH)
                   |           |          |          |         |      |
                   |      172.60.0.10     |     172.60.0.20    |      |
                   |      +--------+      |     +--------+     |      |
(XMPP-C2S)   5221 -|      |        +======+     |        |=====+      |- 5222 (XMPP-C2S)
(XMPP-S2S)   5261 -|------| XMPP 1 +============+ XMPP 2 |            |- 5262 (XMPP-S2S)
(HTTP-Admin) 9091 -|      |        |            |        |------------|- 9092 (HTTP-Admin)
(BOSH)       7071 -|      +----+---+            +----+---+            |- 7072 (BOSH)
                   |           |                     |                |
                   |           |                     |                |
                   |       +---+--+                  |                |
                   |       |      |                  |                |
(Database)   5432 -|-------|  DB  +------------------+                |
                   |       |      |                                   |
                   |       +------+                                   |
                   |      172.60.0.11                                 |
                   |                                                  |
                   +----------------172.60.0.0/24---------------------+
```

Note that the load balancer is configured to be less flappy, with the flappiness controlled by the nginx config, simulating simple round-robin DNS load balancing. Ports from individual servers are exposed and can be hit directly.

Openfire is configured with the following XMPP domain:

* `xmpp.localhost.example`

Openfire is configured with the following hostnames:

* `xmpp1.localhost.example`
* `xmpp2.localhost.example`
* `xmpp3.localhost.example`

The following users are configured:

* `user1` `password`
* `user2` `password`

The following MUC rooms are configured:

* `muc1`
* `muc2`

## The federated domain

The start script will also instantiate a second XMPP domain that consists of one Openfire server. This will result in the following components to be added to the system as described above:

```
                   +------------------------+
                   |       172.60.0.110     |
                   |      +------------+    |
(XMPP-C2S)   5229 -|      |            |    |
(XMPP-S2S)   5269 -|------| OTHER XMPP |    |
(HTTP-Admin) 9099 -|      |            |    |
(BOSH)  7079/7449 -|      +------+-----+    |
                   |             |          |
                   |             |          |
                   |       +-----+----+     |
                   |       |          |     |
(Database)   5433 -|-------| OTHER DB |     |
                   |       |          |     |
                   |       +----------+     |
                   |       172.60.0.111     |
                   |                        |
                   +------172.60.0.0/24-----+
```

The additional Openfire is configured with the following XMPP domain:

* `otherxmpp.localhost.example`

Openfire is configured with the following hostname:

* `otherxmpp.localhost.example`

The following users are configured:

* `user1` `password`
* `user2` `password`

The following MUC rooms are configured:

* `muc1`
* `muc2`

Note that users and MUC rooms on the additional Openfire domain have a similar name to those on the cluster. This does not lead to collisions, as the domain-part of their JIDs will differ.

## Network

The Docker compose file defines a custom bridge network with a single subnet of `172.60.0.0/24` for the clustered configuration.

### Removing a node from the network

To remove a node from the network run the following command:

`docker network disconnect NETWORK-NAME CONTAINER-NAME`

For example:

`docker network disconnect openfire-testing_openfire-federated-net openfire-testing_xmpp1_1`

### Adding a node to the network

To add a node to the network fun the following command:

`docker network connect NETWORK-NAME CONTAINER-NAME`

For example:

`docker network connect openfire-testing_openfire-federated-net openfire-testing_xmpp1_1`