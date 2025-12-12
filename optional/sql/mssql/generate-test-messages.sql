-- =============================================================================
-- Generate Test Messages (~410,000) - MSSQL
-- =============================================================================
--
-- Database: Microsoft SQL Server
-- Compatibility: MSSQL deployments (cluster_mssql)
--
-- Purpose:
--   Generates ~410,000 MUC messages distributed across 2 rooms to simulate a
--   long-running environment experiencing slow startup due to large message
--   history. Useful for testing MUC history loading performance.
--
-- Prerequisites:
--   - Rooms with IDs 1 and 2 must exist (messages alternate between them)
--   - Database should be initialised with Openfire schema
--
-- Usage:
--   Run manually against a running MSSQL database:
--
--   docker exec -it mssql_server /opt/mssql-tools18/bin/sqlcmd \
--     -S localhost -U sa -P 'YourPassword' -d openfire -C \
--     -i /path/to/generate-test-messages.sql
--
-- =============================================================================

USE openfire;
GO

SET NOCOUNT ON;
GO

DECLARE @base_time BIGINT = CAST(DATEDIFF(SECOND, '1970-01-01', GETDATE()) AS BIGINT) * 1000;
DECLARE @msg_id INT = 100;
DECLARE @i INT = 1;
DECLARE @room_id INT;
DECLARE @log_time CHAR(15);
DECLARE @batch_size INT = 1000;

PRINT 'Starting message generation at ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT 'Base time: ' + CAST(@base_time AS VARCHAR(20));

-- Use batch inserts for better performance
WHILE @i <= 410000
BEGIN
    BEGIN TRANSACTION;

    DECLARE @batch_end INT = @i + @batch_size - 1;
    IF @batch_end > 410000 SET @batch_end = 410000;

    WHILE @i <= @batch_end
    BEGIN
        SET @room_id = (@i % 2) + 1;
        SET @log_time = RIGHT(REPLICATE('0', 15) + CAST(@base_time - (CAST(@i AS BIGINT) * 6480) AS VARCHAR(15)), 15);

        INSERT INTO ofMucConversationLog (roomID, messageID, sender, nickname, logTime, subject, body, stanza)
        VALUES (
            @room_id,
            @msg_id,
            'user1@xmpp.localhost.example/resource',
            'User One',
            @log_time,
            NULL,
            'Test message ' + CAST(@i AS VARCHAR(10)),
            NULL
        );

        SET @msg_id = @msg_id + 1;
        SET @i = @i + 1;
    END

    COMMIT TRANSACTION;

    IF (@i - 1) % 50000 = 0
    BEGIN
        PRINT 'Progress: ' + CAST(@i - 1 AS VARCHAR(10)) + ' messages inserted';
    END
END

PRINT 'Message generation complete at ' + CONVERT(VARCHAR, GETDATE(), 120);
GO

-- Set long history configuration using MERGE (MSSQL equivalent of ON CONFLICT)
MERGE INTO ofMucServiceProp AS target
USING (SELECT 1 AS serviceID, 'history.maxNumber' AS name, '1000' AS propValue) AS source
ON target.serviceID = source.serviceID AND target.name = source.name
WHEN MATCHED THEN UPDATE SET propValue = source.propValue
WHEN NOT MATCHED THEN INSERT (serviceID, name, propValue) VALUES (source.serviceID, source.name, source.propValue);
GO

MERGE INTO ofMucServiceProp AS target
USING (SELECT 1 AS serviceID, 'history.type' AS name, 'number' AS propValue) AS source
ON target.serviceID = source.serviceID AND target.name = source.name
WHEN MATCHED THEN UPDATE SET propValue = source.propValue
WHEN NOT MATCHED THEN INSERT (serviceID, name, propValue) VALUES (source.serviceID, source.name, source.propValue);
GO

-- Ensure NO reload limit (worst case scenario)
DELETE FROM ofProperty WHERE name = 'xmpp.muc.history.reload.limit';
GO

-- Verify
SELECT 'Total messages: ' + CAST(COUNT(*) AS VARCHAR(10)) AS result FROM ofMucConversationLog;
SELECT 'Room ' + CAST(roomID AS VARCHAR(5)) + ': ' + CAST(COUNT(*) AS VARCHAR(10)) + ' messages' AS result
FROM ofMucConversationLog GROUP BY roomID ORDER BY roomID;
GO