# Multiple Openfires in Docker
This sets up multiple Openfire servers with associated PostgreSQL DBs in Docker containers for local testing.

Running `./start.sh` will perform some cleanup then start the containers. When running, the system looks like this:

```
                   +---------------------------------------------+
                   |      172.50.0.10           172.50.0.20      |
                   |      +--------+            +--------+       |
                   |      |        |            |        |       |
(XMPP-C2S)   5221 -|------| XMPP 1 +============+ XMPP 2 |-------|- 5222 (XMPP-C2S)
(HTTP-Admin) 9091 -|      |        |            |        |       |- 9092 (HTTP-Admin)
                   |      +----+---+            +----+---+       |
                   |           |                     |           |
                   |           |                     |           |
                   |       +---+--+               +--+---+       |
                   |       |      |               |      |       |
                   |       | DB 1 |               | DB 2 |       |
                   |       |      |               |      |       |
                   |       +------+               +------+       |
                   |      172.50.0.11            172.50.0.21     |
                   |                                             |
                   +----------------172.50.0.0/24----------------+
```

## Default setup
Data and config snapshots have been taken of each DB and Openfire so that a known desired state is configured on start. 
See the "How it's built" section below if you want to understand how this was done or need to add more nodes.

Openfire is configured with the following hostnames:
* `xmpp1.localhost.example`
* `xmpp2.localhost.example`

Each Openfire has the following users:
* `user1` `password`
* `user2` `password`

XMPP 1 hosts the following MUC rooms:
* `muc1`
* `muc2`

## Network
The Docker compose file defines a custom bridge network with a single subnet `172.50.0.0/24`.

### Removing a node from the network
To remove a node from the network run the following command:

    docker network disconnect NETWORK-NAME CONTAINER-NAME

For example:

    docker network disconnect openfire-testing_net-one openfire-testing_xmpp1_1

### Adding a node to the network

To add a node to the network fun the following command:

    docker network connect NETWORK-NAME CONTAINER-NAME

For example:

    docker network connect openfire-testing_net-one openfire-testing_xmpp1_1

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
    net-one:
      ipv4_address: 172.50.0.31

xmpp3:
  image: openfire:fmuc
  ports:
    - "5223:5222"
    - "9093:9090"
  depends_on:
    - "db3"
  networks:
    net-one:
      ipv4_address: 172.50.0.30

networks:
  net-one:
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

    mkdir -p ./sql/3
    mkdir -p ./xmpp/3  

Export the database:

    docker exec -t openfire-testing_db1_1 pg_dump -U openfire openfire > ./sql/3/openfire.sql

Export the Openfire configuration:

    docker cp openfire-testing_xmpp1_1:/var/lib/openfire/conf ./xmpp/3/


Add the new node to the main `docker-compose.yml` including the volume definitions to pull in your exported base 
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
    - ./sql/2:/docker-entrypoint-initdb.d
  networks:
    net-one:
      ipv4_address: 172.50.0.31

xmpp3:
  image: openfire:fmuc
  ports:
    - "5223:5222"
    - "9093:9090"
  depends_on:
    - "db3"
  volumes:
    - ./_data/xmpp/1/conf:/var/lib/openfire/conf
  networks:
    net-one:
      ipv4_address: 172.50.0.30

...

```
