-- =============================================================================
-- Generate Test Messages (~410,000) - PostgreSQL
-- =============================================================================
--
-- Database: PostgreSQL
-- Compatibility: All PostgreSQL deployments (simple, cluster, federation, etc.)
--
-- Purpose:
--   Generates ~410,000 MUC messages distributed across 2 rooms to simulate a
--   long-running environment experiencing slow startup due to large message
--   history. Useful for testing MUC history loading performance.
--
-- Prerequisites:
--   - Rooms with IDs 1 and 2 must exist (messages alternate between them)
--   - Use with 000-init-openfire.sql which creates default rooms
--
-- Usage:
--   Option 1 - Copy to deployment's sql/ directory (runs on container start):
--
--      cp optional/sql/postgresql/generate-test-messages.sql simple/sql/001-generate-test-messages.sql
--      ./start.sh
--
--   Option 2 - Run manually against a running database:
--
--      docker exec -i simple-db-1 psql -U openfire -d openfire \
--        < optional/sql/postgresql/generate-test-messages.sql
--
-- =============================================================================

DO $$
DECLARE
    base_time BIGINT := (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT;
    msg_id INTEGER := 100;
    i INTEGER;
    room_id INTEGER;
    log_time CHAR(15);
BEGIN
    RAISE NOTICE 'Starting message generation at %', NOW();

    FOR i IN 1..410000 LOOP
        room_id := (i % 2) + 1;
        log_time := LPAD((base_time - (i::BIGINT * 6480))::TEXT, 15, '0');

        INSERT INTO ofmucconversationlog (roomid, messageid, sender, nickname, logtime, subject, body, stanza)
        VALUES (
            room_id,
            msg_id,
            'user1@xmpp.localhost.example/resource',
            'User One',
            log_time,
            NULL,
            'Test message ' || i,
            NULL
        );

        msg_id := msg_id + 1;

        IF i % 50000 = 0 THEN
            RAISE NOTICE 'Progress: % messages inserted', i;
        END IF;
    END LOOP;

    RAISE NOTICE 'Message generation complete at %', NOW();
END $$;

-- Set long history configuration
INSERT INTO ofmucserviceprop (serviceid, name, propvalue)
VALUES (1, 'history.maxNumber', '1000')
ON CONFLICT (serviceid, name) DO UPDATE SET propvalue = '1000';

INSERT INTO ofmucserviceprop (serviceid, name, propvalue)
VALUES (1, 'history.type', 'number')
ON CONFLICT (serviceid, name) DO UPDATE SET propvalue = 'number';

-- Ensure NO reload limit (worst case scenario)
DELETE FROM ofproperty WHERE name = 'xmpp.muc.history.reload.limit';

-- Verify
SELECT 'Total messages: ' || COUNT(*)::TEXT FROM ofmucconversationlog;
SELECT 'Room ' || roomid || ': ' || COUNT(*)::TEXT || ' messages' FROM ofmucconversationlog GROUP BY roomid ORDER BY roomid;
