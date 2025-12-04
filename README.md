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
3. Launch the environment using the `start.sh` in the directory of your choice.

## Deployment Options

Each directory contains a different deployment configuration. Choose the one that matches your testing scenario:

| Directory | Description |
|-----------|-------------|
| `simple/` | Single Openfire server with PostgreSQL database. The simplest configuration for basic testing and development. |
| `federation/` | Two independent Openfire servers on separate domains (`xmpp1.localhost.example` and `xmpp2.localhost.example`), each with their own database. Use this to test server-to-server (S2S) federation between XMPP domains. |
| `cluster/` | Three Openfire servers sharing a single database, with an nginx load balancer. Tests Openfire's clustering capabilities using the Hazelcast plugin. |
| `cluster_with_federation/` | A 3-node Openfire cluster plus an additional standalone Openfire server on a different domain (`otherxmpp.localhost.example`). Use this to test clustering and federation simultaneously. |
| `proxy/` | Single Openfire server with an nginx reverse proxy in front. Use this to test proxy configurations and header handling. |

All configurations support optional IPv6 networking via the `-6` flag to `start.sh`. See the README in each directory for detailed information about ports, users, and network configuration.

## How it's built

To recreate the known good state for the system we first create base Openfire and relevant database containers. We then perform the manual setup and any other configuration that we require, such as adding users and MUC rooms. Once the setup is complete we dump the database from the container to the Docker host and copy the Openfire config files from the container to the Docker host. These are then used with Docker volumes for creating the same state in subsequent Openfire and database containers.

## SQL Initialisation Scripts

Each deployment option includes SQL files in a `sql/` directory that are mounted to `/docker-entrypoint-initdb.d` in the PostgreSQL container. PostgreSQL executes these files **alphabetically** on first startup.

SQL files use numeric prefixes to control execution order:

- `000-init-openfire.sql` - Schema initialisation (must run first)
- `001-*.sql`, `002-*.sql`, etc. - Additional seed data or configuration

If you need to add custom SQL scripts (e.g., for test data or configuration), use an appropriate numeric prefix to ensure correct execution order.

## Remote Debugging

All Openfire containers are configured with Java remote debugging enabled via JDWP. The debug agent runs in non-blocking mode (`suspend=n`), so containers start normally without waiting for a debugger to attach.

Debug ports are exposed on localhost:

| Server | Port |
|--------|------|
| xmpp1 (or xmpp) | 5005 |
| xmpp2 | 5006 |
| xmpp3 | 5007 |
| otherxmpp | 5008 |

To attach your IDE, create a remote debug configuration pointing to `localhost` on the appropriate port.
