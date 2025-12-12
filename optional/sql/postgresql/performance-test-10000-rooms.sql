-- =============================================================================
-- Performance Test: 10,000 Minimal MUC Rooms - PostgreSQL
-- =============================================================================
--
-- Database: PostgreSQL
-- Compatibility: All PostgreSQL deployments (simple, cluster, federation, etc.)
--
-- Purpose:
--   Creates 10,000 MUC rooms with minimal data for testing parallel loading
--   performance at scale. Each room includes:
--   - Basic room metadata
--   - Single owner affiliation
--   - No message history (focus on room loading, not history)
--
--   This is ideal for testing MUC room loading performance when you need many
--   rooms but don't need message history to slow things down.
--
-- Note:
--   This script replaces any existing rooms (uses room IDs 1-10000).
--   For a smaller, more realistic dataset with messages and affiliations,
--   see performance-test-200-rooms-with-data.sql instead.
--
-- Usage:
--   Option 1 - Copy to deployment's sql/ directory (runs on container start):
--
--      cp optional/sql/postgresql/performance-test-10000-rooms.sql simple/sql/001-perf-rooms.sql
--      ./start.sh
--
--   Option 2 - Run manually against a running database:
--
--      docker exec -i simple-db-1 psql -U openfire -d openfire \
--        < optional/sql/postgresql/performance-test-10000-rooms.sql
--
-- =============================================================================

DO $$
DECLARE
    base_time BIGINT := (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT;
    batch_size INTEGER := 1000;
    i INTEGER;
BEGIN
    RAISE NOTICE 'Creating 10,000 performance test MUC rooms...';
    RAISE NOTICE 'Current time (ms): %', base_time;
    RAISE NOTICE 'Using batch inserts for efficiency...';

    -- Create rooms 1 through 10,000 using generate_series for efficiency
    -- Insert rooms in batches to avoid memory issues
    FOR i IN 0..9 LOOP
        INSERT INTO ofmucroom (
            serviceid, roomid, creationdate, modificationdate, name, naturalname, description,
            lockeddate, emptydate, canchangesubject, maxusers, publicroom, moderated,
            membersonly, caninvite, roompassword, candiscoverjid, logenabled,
            subject, rolestobroadcast,
            usereservednick, canchangenick, canregister, allowpm, fmucenabled,
            fmucoutboundnode, fmucoutboundmode, fmucinboundnodes
        )
        SELECT
            1,                          -- serviceid
            room_num,                   -- roomid
            LPAD((base_time - (room_num * 10000))::TEXT, 15, '0'),  -- creationdate
            LPAD((base_time - (room_num * 10000))::TEXT, 15, '0'),  -- modificationdate
            'perftest' || room_num::TEXT,  -- name
            'Performance Test Room ' || room_num::TEXT,  -- naturalname
            'Test room for parallel loading performance testing',  -- description
            '000000000000000',          -- lockeddate (not locked)
            LPAD((base_time - (room_num * 10000))::TEXT, 15, '0'),  -- emptydate
            1,                          -- canchangesubject
            50,                         -- maxusers
            1,                          -- publicroom
            0,                          -- moderated
            0,                          -- membersonly
            1,                          -- caninvite
            NULL,                       -- roompassword
            1,                          -- candiscoverjid
            1,                          -- logenabled
            'Welcome to performance test room ' || room_num::TEXT,  -- subject
            7,                          -- rolestobroadcast (all roles)
            0,                          -- usereservednick
            1,                          -- canchangenick
            1,                          -- canregister
            1,                          -- allowpm (anyone)
            0,                          -- fmucenabled
            NULL,                       -- fmucoutboundnode
            NULL,                       -- fmucoutboundmode
            NULL                        -- fmucinboundnodes
        FROM generate_series((i * batch_size) + 1, (i + 1) * batch_size) AS room_num;

        RAISE NOTICE 'Batch %: Inserted rooms % to %', i + 1, (i * batch_size) + 1, (i + 1) * batch_size;
    END LOOP;

    RAISE NOTICE 'Room creation complete. Creating affiliations...';

    -- Create owner affiliations in batches (one owner per room)
    FOR i IN 0..9 LOOP
        INSERT INTO ofmucaffiliation (roomid, jid, affiliation)
        SELECT
            room_num,
            'owner' || room_num::TEXT || '@xmpp.localhost.example',
            10  -- owner affiliation
        FROM generate_series((i * batch_size) + 1, (i + 1) * batch_size) AS room_num;

        RAISE NOTICE 'Batch %: Created affiliations for rooms % to %', i + 1, (i * batch_size) + 1, (i + 1) * batch_size;
    END LOOP;

    RAISE NOTICE 'Performance test room creation complete.';
    RAISE NOTICE 'Total rooms created: 10,000';
    RAISE NOTICE 'Total affiliations created: %', (SELECT COUNT(*) FROM ofmucaffiliation WHERE roomid BETWEEN 1 AND 10000);
END $$;

-- Set history configuration for the service
INSERT INTO ofmucserviceprop (serviceid, name, propvalue)
VALUES (1, 'history.maxNumber', '100')
ON CONFLICT (serviceid, name) DO UPDATE SET propvalue = '100';

INSERT INTO ofmucserviceprop (serviceid, name, propvalue)
VALUES (1, 'history.type', 'number')
ON CONFLICT (serviceid, name) DO UPDATE SET propvalue = 'number';

-- Verify data
SELECT 'Total rooms: ' || COUNT(*)::TEXT AS summary FROM ofmucroom;
SELECT 'Total affiliations: ' || COUNT(*)::TEXT AS summary FROM ofmucaffiliation;
SELECT 'Total messages: ' || COUNT(*)::TEXT AS summary FROM ofmucconversationlog;
SELECT 'Sample - Messages per room (first 10):' AS summary;
SELECT 'Room ' || roomid || ': ' || COUNT(*)::TEXT || ' messages' AS detail
FROM ofmucconversationlog
WHERE roomid <= 10
GROUP BY roomid
ORDER BY roomid;