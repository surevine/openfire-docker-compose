-- =============================================================================
-- Create 50 MUC Rooms - PostgreSQL
-- =============================================================================
--
-- Database: PostgreSQL
-- Compatibility: All PostgreSQL deployments (simple, cluster, federation, etc.)
--
-- Purpose:
--   Creates 48 additional MUC rooms (IDs 3-50) to supplement the 2 default rooms,
--   giving a total of ~50 rooms. Also redistributes any existing messages evenly
--   across all 50 rooms.
--
--   Useful for testing environments that need a moderate number of rooms with
--   message history spread across them.
--
-- Prerequisites:
--   - Rooms with IDs 1 and 2 should already exist (from 000-init-openfire.sql)
--   - Best used after generate-test-messages.sql to have messages to redistribute
--
-- Usage:
--   Option 1 - Copy to deployment's sql/ directory (runs on container start):
--
--      cp optional/sql/postgresql/create-50-rooms.sql simple/sql/002-create-50-rooms.sql
--      ./start.sh
--
--   Option 2 - Run manually against a running database:
--
--      docker exec -i simple-db-1 psql -U openfire -d openfire \
--        < optional/sql/postgresql/create-50-rooms.sql
--
-- =============================================================================

DO $$
DECLARE
    i INTEGER;
    room_name VARCHAR(50);
    creation_time CHAR(15);
    base_time BIGINT := (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT;
BEGIN
    RAISE NOTICE 'Creating additional MUC rooms...';
    RAISE NOTICE 'Current time (ms): %', base_time;

    -- Create rooms 3 through 50 (48 additional rooms)
    FOR i IN 3..50 LOOP
        room_name := 'muc' || i::TEXT;
        creation_time := LPAD((base_time - (i * 1000))::TEXT, 15, '0');

        INSERT INTO ofmucroom (
            serviceid, roomid, creationdate, modificationdate, name, naturalname, description,
            lockeddate, emptydate, canchangesubject, maxusers, publicroom, moderated,
            membersonly, caninvite, roompassword, candiscoverjid, logenabled,
            subject, rolestobroadcast,
            usereservednick, canchangenick, canregister, allowpm, fmucenabled,
            fmucoutboundnode, fmucoutboundmode, fmucinboundnodes
        )
        VALUES (
            1,                      -- serviceid
            i,                      -- roomid
            creation_time,          -- creationdate
            creation_time,          -- modificationdate
            room_name,              -- name
            room_name,              -- naturalname
            room_name,              -- description
            '000000000000000',      -- lockeddate (not locked)
            creation_time,          -- emptydate
            0,                      -- canchangesubject
            30,                     -- maxusers
            1,                      -- publicroom
            0,                      -- moderated
            0,                      -- membersonly
            0,                      -- caninvite
            NULL,                   -- roompassword
            1,                      -- candiscoverjid
            1,                      -- logenabled
            '',                     -- subject
            7,                      -- rolestobroadcast
            0,                      -- usereservednick
            1,                      -- canchangenick
            1,                      -- canregister
            0,                      -- allowpm
            0,                      -- fmucenabled
            NULL,                   -- fmucoutboundnode
            NULL,                   -- fmucoutboundmode
            NULL                    -- fmucinboundnodes
        );

        IF i % 10 = 0 THEN
            RAISE NOTICE 'Created room: %', room_name;
        END IF;
    END LOOP;

    RAISE NOTICE 'Room creation complete.';
END $$;

-- Now redistribute messages across all 50 rooms
-- This simulates a more realistic distribution where each room has messages
DO $$
BEGIN
    RAISE NOTICE 'Redistributing messages across all 50 rooms...';

    UPDATE ofmucconversationlog
    SET roomid = (messageid % 50) + 1;

    RAISE NOTICE 'Message redistribution complete.';
END $$;

-- Verify
SELECT 'Total rooms: ' || COUNT(*)::TEXT AS result FROM ofmucroom;
SELECT 'Total messages: ' || COUNT(*)::TEXT AS result FROM ofmucconversationlog;
SELECT 'Messages per room (sample):' AS result;
SELECT 'Room ' || roomid || ': ' || COUNT(*)::TEXT || ' messages' AS result
FROM ofmucconversationlog
GROUP BY roomid
ORDER BY roomid
LIMIT 10;
