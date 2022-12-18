# Proxy configuration

Running `./start.sh` will perform some cleanup then start the containers with an optional proxy.
When running, the system looks like this:

```
                    +--------------------------+
                    |                          |
                    |      172.60.0.99         |
                    |      +--------+          |
(XMPP-C2S)   55222 -|      |        |          |
(XMPP-S2S)   55269 -|------|  Nginx +          |
(HTTP-Admin) 59090 -|      |        |          |
(BOSH)       57070 -|      +----+---+          |
                    |           |              |
                    |           |              |
                    |      172.60.0.10         |
                    |      +--------+          |
(XMPP-C2S)    5222 -|      |        |          |
(XMPP-S2S)    5269 -|------| XMPP 1 +          |
(HTTP-Admin)  9090 -|      |        |          |
(BOSH)        7070 -|      +----+---+          |
                    |           |              |
                    |           |              |
                    |       +---+--+           |
                    |       |      |           |
(Database)    5432 -|-------|  DB  +           |
                    |       |      |           |
                    |       +------+           |
                    |      172.60.0.11         |
                    |                          |
                    +-----172.60.0.0/24--------+
```

Openfire is configured with the following XMPP domain:

* `xmpp.localhost.example`

Openfire is configured with the following FQDN:

* `xmpp1.localhost.example`

The following users are configured:

* `admin` `admin`
* `user1` `password`
* `user2` `password`

The following MUC rooms are configured:

* `muc1`
* `muc2`

## Network

The Docker compose file defines a custom bridge network with a single subnet of `172.60.0.0/24`.
