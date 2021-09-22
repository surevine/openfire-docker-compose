# Multiple Openfires in Docker

Quickly create multiple Openfire servers with associated PostgreSQL DBs in Docker containers for local testing.

Data and config snapshots have been taken of each DB and Openfire server so that a known desired state is configured on start.
See the "How it's built" section below if you want to understand how this was done or need to add more nodes.

## Prerequisites

* Docker - <https://docs.docker.com/engine/install/>
* Docker Compose - <https://docs.docker.com/compose/install/>

    docker build -t openfire:latest .

## Quick Start

1. Make sure you have docker and docker-compose installed
2. Create a local Openfire docker image, tagged `openfire:latest` that contains the version of Openfire that you want to run
    1. run `docker build --tag openfire:latest .` in the root of the Openfire repository (<https://github.com/igniterealtime/Openfire>)
3. Launch the environment
    1. use `./start.sh` if you want two **federated** Openfire instances, or
    2. use `./start.sh -c` if you want three **clustered** Openfire instances.
    3. use `./start.sh -co` if you want a combination: a cluster, with an additional federated Instance.

## Federated configuration

Running `./start.sh` will perform some cleanup then start the containers in a federated configuration.
When running, the system looks like this:

```
                   +---------------------------------------------+
                   |      172.50.0.10           172.50.0.20      |
                   |      +--------+            +--------+       |
(XMPP-C2S)   5221 -|      |        |            |        |       |- 5222 (XMPP-C2S)
(XMPP-S2S)   5261 -|------| XMPP 1 +============+ XMPP 2 |-------|- 5262 (XMPP-S2S)
(HTTP-Admin) 9091 -|      |        |            |        |       |- 9092 (HTTP-Admin)
(BOSH)  7071/7441 -|      +----+---+            +----+---+       |- 7072/7442 (BOSH)
                   |           |                     |           |
                   |           |                     |           |
                   |       +---+--+               +--+---+       |
                   |       |      |               |      |       |
(Database)   5431 -|-------| DB 1 |               | DB 2 |-------|- 5432 (Database)
                   |       |      |               |      |       |
                   |       +------+               +------+       |
                   |      172.50.0.11            172.50.0.21     |
                   |                                             |
                   +----------------172.50.0.0/24----------------+
```

Openfire is configured with the following hostnames/XMPP domain names:

* `xmpp1.localhost.example`
* `xmpp2.localhost.example`

XMPP 1 has the following users:

* `user1` `password`
* `user2` `password`

XMPP 1 hosts the following MUC rooms:

* `muc1`
* `muc2`

XMPP 2 has the following users:

* `user3` `password`
* `user4` `password`

XMPP 2 hosts the following MUC rooms:

* `muc3`
* `muc4`

## Clustered configuration

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

Note that the load balancer is intentionally configured to be "flappy" to simulate simple round-robin DNS load balancing, but that ports from individual servers are exposed and can be hit directly.

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


### Add a federated domain to the cluster

Running `./start.sh -co` (instead of `./start.sh -c`) will, apart from the cluster described above, also instantiate a second XMPP domain that consists of one Openfire server. This will result in the following components to be added to the system as described above:

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

The Docker compose file defines a custom bridge network with a single subnet (`172.50.0.0/24` for the federated
configuration and `172.60.0.0/24` for the clustered).

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

## How it's built

To recreate the known good state for the system we first create base Openfire and Postgres containers.
We then perform the manual setup and any other configuration that we require, such as adding users and MUC rooms.
Once the setup is complete we dump the database from the container to the Docker host and copy the Openfire config
files from the container to the Docker host. These are then used with Docker volumes for creating the same state in
subsequent Openfire and Postgres containers.

### Adding a new node

Configure a docker-compose file to stand up:

   1. a base Openfire container (named `xmpp3`)
   1. a base Postgres Docker container (named `db3`)

We will use these containers to configure our third node before exporting the DB and Openfire configuration.
Be sure to set the correct IP addresses and increment the host port numbers so they don't clash with existing exposed ports.
The convention I have followed is to increment the IP addresses by 10 and the port numbers by 1:

For `xmpp1`

* Openfire IP: `172.50.0.10`
* DB IP: `172.50.0.11`
* XMPP port: `5221`
* Admin port: `9091`

For `xmpp2`

* Openfire IP: `172.50.0.20`
* DB IP: `172.50.0.21`
* XMPP port: `5222`
* Admin port: `9092`

Example docker-compose file for our third node:

```
db3:
  image: library/postgres:9.6.17-alpine
  environment:
    - "POSTGRES_DB=openfire"
    - "POSTGRES_USER=openfire"
    - "POSTGRES_PASSWORD=hunter2"
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.31

xmpp3:
  image: openfire:latest
  ports:
    - "5223:5222"
    - "9093:9090"
  depends_on:
    - "db3"
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.30

networks:
  openfire-federated-net:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.50.0.0/24
```

Run this with `docker-compose up`. Once running navigate to `http://localhost:9093` and manually configure the Openfire server.
The database hostname should be the name of the DB node in the compose file (so `db3` in this case).
You should also get the database name, username, and password, from the compose file.

Create any configuration you require (e.g. adding users).

Create directories for the exported DB and config:

```
mkdir -p ./sql/3
mkdir -p ./xmpp/3  
```

Export the database:

`docker exec -t openfire-testing_db3_1 pg_dump -U openfire openfire > ./sql/3/openfire.sql`

Export the Openfire configuration:

`docker cp openfire-testing_xmpp3_1:/var/lib/openfire/conf ./xmpp/3/`

Add the new node to the main `docker-compose-federated.yml` including the volume definitions to pull in your exported base
configuration data:

```
...

db3:
  image: library/postgres:9.6.17-alpine
  environment:
    - "POSTGRES_DB=openfire"
    - "POSTGRES_USER=openfire"
    - "POSTGRES_PASSWORD=hunter2"
  volumes:
    - ./sql/3:/docker-entrypoint-initdb.d
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.31

xmpp3:
  image: openfire:latest
  ports:
    - "5223:5222"
    - "9093:9090"
  depends_on:
    - "db3"
  volumes:
    - ./_data/xmpp/3/conf:/var/lib/openfire/conf
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.30

...

```
