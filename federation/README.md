# Federated configuration

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

## Hosts file entries
To access the XMPP servers and (optional) OCSP responder from your local machine you should 
add entries to your hosts file:

```
127.0.0.1 xmpp.localhost.example
127.0.0.1 xmpp1.localhost.example
127.0.0.1 xmpp2.localhost.example
127.0.0.1 xmpp3.localhost.example
127.0.0.1 ocsp.localhost.example
```

This helps when testing with various clients and tools.

## Network

The Docker compose file defines a custom bridge network with a single subnet of `172.50.0.0/24`

When the `-6` argument to `./start.sh` is provided, then an additional subnet of `fd23:0d79:d076::/64` is configured.
Then, IPv6 is preferred for internal networking. Note that the IPv4 network remains in place, as Docker does not support
IPv6-only containers.

When running with the optional `-6` and `-o` flags (that add IPv6 and OCSP support 
respectively), and the system looks like this:

```
                   +---------------------------------------------+
                   |  [fd23:d79:d076::10]  [fd23:d79:d076::20]   |
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
                   |  [fd23:d79:d076::11]  [fd23:d79:d076::21]   |
                   |                                             |
                   |               +-----------+                 |
(OCSP)       8888 -|---------------|   OCSP    |                 |
                   |               | Responder |                 |
                   |               +-----------+                 |
                   |                172.50.0.88                  |
                   |            [fd23:d79:d076::88]              |
                   |                                             |
                   |                                             |
                   +----------------172.50.0.0/24----------------+
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

## Certificates

By default, the system uses self-signed certificates that have been pre-generated and added 
to the identity and trust stores for `xmpp1.localhost.example` and `xmpp2.localhost.example`.

This simplifies the setup process and avoids the need to generate certificates, but the
limitations of this are that the certificates are not trusted by anything other than 
our own servers (`xmpp1` and `xmpp2`), and that they do not support OCSP (Online Certificate 
Status Protocol).

### OCSP Support
A more fully featured solution is provided by the `-o` option of the `start.sh` script 
which enables OCSP support for the Openfire federated environment. When passed the `-o` 
option the script will generate a complete certificate hierarchy with OCSP support, and 
deploy an OCSP responder service configured to respond to OCSP requests for the server 
certificates. 

Here's what the script creates:

* Root CA certificate (self-signed)
* Intermediate CA certificate (signed by Root CA)
* Two server certificates with OCSP information (one for each Openfire instance)
* An OCSP responder certificate (for signing OCSP responses)
* Full certificate chains for each XMPP server (server + intermediate + root)
* Certificate database (index.txt) for the OCSP responder to track certificate statuses

All certificates are stored in `./_data/certs/`.

```
                           Root CA
                      (Top level trust root)
                      (Kept offline/secure)
                              |
                              v
                       Intermediate CA
                  (Day-to-day certificate issuer)
                  (OCSP configuration point)
                              |
         +--------------------+------------------+
         v                    v                  v
    XMPP1 Cert            XMPP2 Cert         OCSP Cert
         |                    |              (Signs OCSP responses)
         v                    v
   XMPP1 Server          XMPP2 Server
    [keystore]             [keystore]
    (server's identity)    (server's identity)
    [truststore]           [truststore]
    (who to trust)         (who to trust)
```

This setup allows certificates to be checked for revocation status making a request to the 
OCSP responder:
```bash
openssl ocsp -url http://localhost:8888 \
    -issuer _data/certs/ca/intermediate-ca/intermediate.crt \
    -CAfile _data/certs/xmpp1_chain.pem \
    -cert _data/certs/xmpp1.crt \
    -text
```

### Certificate Revocation

The `./scripts/revocation.sh` script allows you to revoke SSL certificates and 
update the OCSP responder's database. You can also un-revoke certificates 
that were previously revoked. 

**Important:** Run this script from the root `federation/` directory, as it requires 
direct access to the `_data` directory containing the certificates and PKI infrastructure.

```bash
./scripts/revocation.sh --server xmpp1 [--reason reason] [--unrevoke]
```

Available revocation reasons:
- unspecified (default)
- keyCompromise
- CACompromise
- affiliationChanged
- superseded
- cessationOfOperation
- certificateHold

Examples:
```bash
# Revoke xmpp1's certificate
./scripts/revocation.sh --server xmpp1

# Revoke with specific reason
./scripts/revocation.sh --server xmpp1 --reason keyCompromise

# Remove revocation status
./scripts/revocation.sh --server xmpp1 --unrevoke
```

To verify the current status:
```bash
openssl ocsp -url http://localhost:8888 \
    -issuer _data/certs/ca/intermediate-ca/intermediate.crt \
    -CAfile _data/certs/xmpp1_chain.pem \
    -cert _data/certs/xmpp1.crt \
    -text
```

Note: The first OCSP status check may return the previous status. Run 
the check again if this happens - subsequent checks will show the 
current status.

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

* Openfire IP: `172.50.0.10` / `fd23:d79:d076::10`
* DB IP: `172.50.0.11` / `fd23:d79:d076::11`
* XMPP port: `5221`
* Admin port: `9091`

For `xmpp2`

* Openfire IP: `172.50.0.20` / `fd23:d79:d076::20`
* DB IP: `172.50.0.21` / `fd23:d79:d076::21`
* XMPP port: `5222`
* Admin port: `9092`

Example docker-compose file for our third node:

```
db3:
  image: library/postgres:9.6.24-alpine
  environment:
    - "POSTGRES_DB=openfire"
    - "POSTGRES_USER=openfire"
    - "POSTGRES_PASSWORD=hunter2"
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.31
      ipv6_address: fd23:d79:d076::31

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
      ipv6_address: fd23:d79:d076::30

networks:
  openfire-federated-net:
    driver: bridge
    enable_ipv6: true
    ipam:
      driver: default
      config:
        - subnet: 172.50.0.0/24
        - subnet: fd23:0d79:d076::/64
```

Run this with the `start.sh`. Once running navigate to `http://localhost:9093` and manually configure the Openfire server.
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
  image: library/postgres:9.6.24-alpine
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

Add the IPv4-only network definition in `docker-compose-federated-ipv4-only.yml`:

```
...

db3:
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.31

xmpp3:
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.30
...

```

Add the dual-stack network definition in `docker-compose-federated-dualstack.yml` (note that this also includes IPv4 config):

```
...

db3:
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.31
      ipv6_address: fd23:d79:d076::31

xmpp3:
  networks:
    openfire-federated-net:
      ipv4_address: 172.50.0.30
      ipv6_address: fd23:d79:d076::30
...

```

Lastly, add the new host in all `extra_hosts` configuration blocks.