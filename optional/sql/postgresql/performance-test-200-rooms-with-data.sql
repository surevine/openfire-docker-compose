-- =============================================================================
-- Performance Test: 200 Rooms with Realistic Data - PostgreSQL
-- =============================================================================
--
-- Database: PostgreSQL
-- Compatibility: All PostgreSQL deployments (simple, cluster, federation, etc.)
--
-- Purpose:
--   Creates 200 MUC rooms with realistic data for testing parallel loading
--   performance. Each room includes:
--   - Varied affiliations (1 owner, 1-2 admins, 3-5 members)
--   - Message history (100-500 messages per room, ~60,000 total)
--   - Realistic metadata
--
--   This is ideal when you need a realistic dataset with varied affiliations
--   and message history to test how Openfire handles loading complete room data.
--
-- Note:
--   This script replaces any existing rooms (uses room IDs 1-200).
--   For high-volume room testing without message history, see
--   performance-test-10000-rooms.sql instead.
--
-- Usage:
--   Option 1 - Copy to deployment's sql/ directory (runs on container start):
--
--      cp optional/sql/postgresql/performance-test-200-rooms-with-data.sql simple/sql/001-perf-rooms.sql
--      ./start.sh
--
--   Option 2 - Run manually against a running database:
--
--      docker exec -i simple-db-1 psql -U openfire -d openfire \
--        < optional/sql/postgresql/performance-test-200-rooms-with-data.sql
--
-- =============================================================================

DO $$
DECLARE
    i INTEGER;
    j INTEGER;
    room_name VARCHAR(50);
    creation_time CHAR(15);
    base_time BIGINT := (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT;
    msg_id INTEGER := 1000000;
    room_id_val INTEGER;
    message_count INTEGER;
    affiliation_count INTEGER;
BEGIN
    RAISE NOTICE 'Creating 200 performance test MUC rooms...';
    RAISE NOTICE 'Current time (ms): %', base_time;

    -- Create rooms 1 through 200
    FOR i IN 1..200 LOOP
        room_name := 'perftest' || i::TEXT;
        creation_time := LPAD((base_time - (i * 10000))::TEXT, 15, '0');

        INSERT INTO ofmucroom (
            serviceid, roomid, creationdate, modificationdate, name, naturalname, description,
            lockeddate, emptydate, canchangesubject, maxusers, publicroom, moderated,
            membersonly, caninvite, roompassword, candiscoverjid, logenabled,
            subject, rolestobroadcast,
            usereservednick, canchangenick, canregister, allowpm, fmucenabled,
            fmucoutboundnode, fmucoutboundmode, fmucinboundnodes
        )
        VALUES (
            1,                          -- serviceid
            i,                          -- roomid
            creation_time,              -- creationdate
            creation_time,              -- modificationdate
            room_name,                  -- name
            'Performance Test Room ' || i::TEXT,  -- naturalname
            'Test room for parallel loading performance testing',  -- description
            '000000000000000',          -- lockeddate (not locked)
            creation_time,              -- emptydate
            1,                          -- canchangesubject
            50,                         -- maxusers
            1,                          -- publicroom
            0,                          -- moderated
            0,                          -- membersonly
            1,                          -- caninvite
            NULL,                       -- roompassword
            1,                          -- candiscoverjid
            1,                          -- logenabled
            'Welcome to performance test room ' || i::TEXT,  -- subject
            7,                          -- rolestobroadcast (all roles)
            0,                          -- usereservednick
            1,                          -- canchangenick
            1,                          -- canregister
            1,                          -- allowpm (anyone)
            0,                          -- fmucenabled
            NULL,                       -- fmucoutboundnode
            NULL,                       -- fmucoutboundmode
            NULL                        -- fmucinboundnodes
        )
        RETURNING roomid INTO room_id_val;

        -- Add affiliations for this room
        -- Each room gets: 1 owner, 1-2 admins, 3-5 members
        affiliation_count := 3 + (i % 3); -- 3-5 affiliations per room

        -- Owner
        INSERT INTO ofmucaffiliation (roomid, jid, affiliation)
        VALUES (room_id_val, 'owner' || i::TEXT || '@xmpp.localhost.example', 10);

        -- Admin(s)
        FOR j IN 1..(1 + (i % 2)) LOOP
            INSERT INTO ofmucaffiliation (roomid, jid, affiliation)
            VALUES (room_id_val, 'admin' || i::TEXT || '-' || j::TEXT || '@xmpp.localhost.example', 20);
        END LOOP;

        -- Members
        FOR j IN 1..(3 + (i % 3)) LOOP
            INSERT INTO ofmucaffiliation (roomid, jid, affiliation)
            VALUES (room_id_val, 'member' || i::TEXT || '-' || j::TEXT || '@xmpp.localhost.example', 30);
        END LOOP;

        -- Add message history for this room
        -- Each room gets 100-500 messages (varies by room number)
        message_count := 100 + ((i * 37) % 401); -- Pseudo-random 100-500

        FOR j IN 1..message_count LOOP
            INSERT INTO ofmucconversationlog (roomid, messageid, sender, nickname, logtime, subject, body, stanza)
            VALUES (
                room_id_val,
                msg_id,
                'user' || ((j % 10) + 1)::TEXT || '@xmpp.localhost.example/resource',
                'User ' || ((j % 10) + 1)::TEXT,
                LPAD((base_time - (j::BIGINT * 60000))::TEXT, 15, '0'), -- 1 minute intervals
                CASE WHEN j % 50 = 1 THEN 'Discussion topic ' || (j/50 + 1)::TEXT ELSE NULL END,
                'Test message ' || j::TEXT || ' in room ' || room_name,
                NULL
            );
            msg_id := msg_id + 1;
        END LOOP;

        IF i % 20 = 0 THEN
            RAISE NOTICE 'Created room % with % affiliations and % messages', room_name, affiliation_count, message_count;
        END IF;
    END LOOP;

    RAISE NOTICE 'Performance test room creation complete.';
    RAISE NOTICE 'Total rooms created: 200';
    RAISE NOTICE 'Total affiliations created: %', (SELECT COUNT(*) FROM ofmucaffiliation);
    RAISE NOTICE 'Total messages created: %', (SELECT COUNT(*) FROM ofmucconversationlog);
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