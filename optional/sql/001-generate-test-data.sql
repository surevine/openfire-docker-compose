-- =============================================================================
-- Generate Test Data: Slow Startup Issue Recreation
-- =============================================================================
--
-- Compatibility: all deployments (simple, cluster, federation, cluster_with_federation, proxy)
--
-- Purpose:
--   Generates ~410,000 MUC messages to simulate a long-running environment
--   experiencing slow startup due to large message history.
--
-- Usage:
--   1. Copy this file to your deployment's sql/ directory:
--
--      cp optional/sql/001-generate-test-data.sql simple/sql/
--
--   2. Restart containers (or start fresh if DB already initialised):
--
--      ./start.sh
--
--   Alternatively, run manually against a running database:
--
--      docker exec -i simple-db-1 psql -U openfire -d openfire < optional/sql/001-generate-test-data.sql
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
