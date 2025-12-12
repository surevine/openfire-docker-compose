# Optional SQL Scripts

This directory contains optional SQL scripts for generating test data in Openfire Docker environments. These scripts are useful for performance testing, debugging, and simulating production-like environments.

## Directory Structure

```
optional/sql/
├── postgresql/          # Scripts for PostgreSQL databases
│   ├── generate-test-messages.sql
│   ├── create-50-rooms.sql
│   ├── performance-test-10000-rooms.sql
│   ├── performance-test-200-rooms-with-data.sql
│   └── set-worker-count.sql
└── mssql/               # Scripts for Microsoft SQL Server
    ├── generate-test-messages.sql
    └── create-50-rooms.sql
```

## Available Scripts

### PostgreSQL Scripts

| Script | Purpose |
|--------|---------|
| `generate-test-messages.sql` | Generates ~410,000 MUC messages across 2 rooms. Useful for testing slow startup issues due to large message history. |
| `create-50-rooms.sql` | Creates 48 additional rooms (IDs 3-50) and redistributes messages across all 50 rooms. |
| `performance-test-10000-rooms.sql` | Creates 10,000 minimal rooms with single owner affiliation. Ideal for testing room loading at scale without message history overhead. |
| `performance-test-200-rooms-with-data.sql` | Creates 200 rooms with realistic data: varied affiliations (owners, admins, members) and 100-500 messages per room (~60,000 total). |
| `set-worker-count.sql` | Template for setting the `xmpp.muc.loading.workers` property to control parallel room loading. |

### MSSQL Scripts

| Script | Purpose |
|--------|---------|
| `generate-test-messages.sql` | MSSQL version of the 410,000 message generator. |
| `create-50-rooms.sql` | MSSQL version of the 50 rooms creator. |

## Usage

### Option 1: Copy to deployment directory (recommended for testing)

Copy the desired script to your deployment's `sql/` directory with a numbered prefix:

```bash
# For simple deployment with 10,000 rooms
cp optional/sql/postgresql/performance-test-10000-rooms.sql simple/sql/001-perf-rooms.sql

# Start fresh (removes existing database)
./start.sh
```

Scripts in the `sql/` directory run automatically on container startup via PostgreSQL's `docker-entrypoint-initdb.d` mechanism.

### Option 2: Run manually against running database

```bash
# PostgreSQL example
docker exec -i simple-db-1 psql -U openfire -d openfire \
  < optional/sql/postgresql/generate-test-messages.sql

# MSSQL example
docker exec -it mssql_server /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'YourPassword' -d openfire -C \
  -i /path/to/script.sql
```

## Choosing a Test Dataset

| Use Case | Recommended Script |
|----------|-------------------|
| Test MUC history loading performance | `generate-test-messages.sql` + `create-50-rooms.sql` |
| Test room loading at scale (many rooms, no messages) | `performance-test-10000-rooms.sql` |
| Test realistic room loading (rooms with affiliations + messages) | `performance-test-200-rooms-with-data.sql` |
| Test parallel worker configuration | Any data script + `set-worker-count.sql` |

## Notes

- Scripts numbered `001-*` onwards run after `000-init-openfire.sql` (the base schema)
- Some scripts (like `create-50-rooms.sql`) expect existing rooms/messages to work with
- Performance test scripts replace existing rooms, so use on fresh databases
- Worker count changes require an Openfire restart to take effect
