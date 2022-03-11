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

## How it's built

To recreate the known good state for the system we first create base Openfire and relevant database containers. We then perform the manual setup and any other configuration that we require, such as adding users and MUC rooms. Once the setup is complete we dump the database from the container to the Docker host and copy the Openfire config files from the container to the Docker host. These are then used with Docker volumes for creating the same state in subsequent Openfire and database containers.
