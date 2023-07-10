# Openfire Dockerfile

Originally derived from luzifer-docker / openfire

Run Openfire XMPP server in a Docker container

## Usage

```bash
## Build container (optional)
$ docker build -t openfire .

## Execute curator
$ docker run --rm -ti -v /data/openfire:/data openfire

## Persistence including config and keystore will be created
$ tree /data/openfire
/data/openfire
├── conf
│   ├── available-plugins.xml
│   ├── crowd.properties
│   ├── openfire.xml
│   ├── security.xml
│   └── server-update.xml
├── embedded-db
│   ├── openfire.lck
│   ├── openfire.log
│   ├── openfire.properties
│   ├── openfire.script
│   └── openfire.tmp
└── security
    └── keystore

4 directories, 10 files
```
