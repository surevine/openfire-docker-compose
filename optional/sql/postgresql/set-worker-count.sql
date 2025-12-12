-- =============================================================================
-- Set MUC Room Loading Worker Count - PostgreSQL
-- =============================================================================
--
-- Database: PostgreSQL
-- Compatibility: All PostgreSQL deployments (simple, cluster, federation, etc.)
--
-- Purpose:
--   Sets the xmpp.muc.loading.workers property in the database.
--   This controls how many parallel workers are used to load MUC rooms
--   from the database during Openfire startup.
--
-- Usage:
--   -- For sequential loading (1 worker):
--   docker exec -i openfire-db-1 psql -U openfire -d openfire <<EOF
--   DELETE FROM ofproperty WHERE name = 'xmpp.muc.loading.workers';
--   INSERT INTO ofproperty (name, propvalue) VALUES ('xmpp.muc.loading.workers', '1');
--   EOF
--
--   -- For parallel loading (3 workers):
--   docker exec -i openfire-db-1 psql -U openfire -d openfire <<EOF
--   DELETE FROM ofproperty WHERE name = 'xmpp.muc.loading.workers';
--   INSERT INTO ofproperty (name, propvalue) VALUES ('xmpp.muc.loading.workers', '3');
--   EOF
--
--   -- For parallel loading (5 workers):
--   docker exec -i openfire-db-1 psql -U openfire -d openfire <<EOF
--   DELETE FROM ofproperty WHERE name = 'xmpp.muc.loading.workers';
--   INSERT INTO ofproperty (name, propvalue) VALUES ('xmpp.muc.loading.workers', '5');
--   EOF
--
-- Note: The value will be read during Openfire startup, so you need to
--       restart Openfire after changing this property.
--
-- =============================================================================

-- This file is a template - actual values are set dynamically by the test script
-- Default to 1 worker (sequential) if run standalone
DELETE FROM ofproperty WHERE name = 'xmpp.muc.loading.workers';
INSERT INTO ofproperty (name, propvalue) VALUES ('xmpp.muc.loading.workers', '1');

SELECT 'Property set: ' || name || ' = ' || propvalue AS result
FROM ofproperty
WHERE name = 'xmpp.muc.loading.workers';