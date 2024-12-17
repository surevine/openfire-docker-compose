# Clustered configuration

Running `./start.sh -c` will perform some cleanup then start the containers in a clustered configuration.
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

Note that the load balancer is configured to be less flappy, with the flappiness controlled by the nginx config, 
simulating simple round-robin DNS load balancing. Ports from individual servers are exposed and can be hit directly.

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


## Hosts file entries
To access the XMPP servers and load balancer from your local machine you should
add entries to your hosts file:

```
127.0.0.1 openfire-lb-1
127.0.0.1 xmpp.localhost.example
127.0.0.1 xmpp1.localhost.example
127.0.0.1 xmpp2.localhost.example
127.0.0.1 xmpp3.localhost.example
```

## Client configuration
Depending on your requirements, you can configure your client to connect via the load balancer 
at `openfire-lb-1:55222` or directly to the individual servers at:
- `xmpp1.localhost.example:5221` 
- `xmpp2.localhost.example:5222`
- `xmpp3.localhost.example:5223`

## Network

The Docker compose file defines a custom bridge network with a single subnet of `172.60.0.0/24` for the clustered configuration.

When the `-6` argument to `./start.sh` is provided, then an additional subnet of `fd23:0d79:d076::/64` is configured.
Then, IPv6 is preferred for internal networking. Note that the IPv4 network remains in place, as Docker does not support
IPv6-only containers.

When running with the optional `-6` flag (that adds IPv6 support) the system looks like this:

```
                   +--------------------------------------------------+
                   |       [fd23:d79:d076::99]                        |
                   |           172.60.0.99                            |
                   |       +----------------+                         |
                   |       |                |+--------------+         |
(XMPP-C2S)  55222 -|-------|  Load Balancer |+-------+      |         |
(BOSH)      57070 -|       |                |        |      |         |
(BOSHS)     57443 -|       +----------------+        |      |         |
                   |           |                     | [fd23:d79:d076::30]
                   |           |                     |  172.60.0.30   |
                   |           |                     |  +--------+    |
                   |           |          +=============+        |    |- 5223 (XMPP-C2S)
                   |           |          |          |  | XMPP 3 |----|- 5263 (XMPP-S2S)
                   |           |          |          |  |        |    |- 9093 (HTTP-Admin)
                   |           |          |          |  +------+-+    |- 7073 (BOSH)
                   |           |          |          |         |      |
                   |  [fd23:d79:d076::10] | [fd23:d79:d076::20]|      |
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
                   |  [fd23:d79:d076::11]                             |
                   |                                                  |
                   +----------------172.60.0.0/24---------------------+
                                 fd23:0d79:d076::/64
```

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