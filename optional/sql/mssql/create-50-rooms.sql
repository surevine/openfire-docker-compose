-- =============================================================================
-- Create 50 MUC Rooms - MSSQL
-- =============================================================================
--
-- Database: Microsoft SQL Server
-- Compatibility: MSSQL deployments (cluster_mssql)
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
--   - Rooms with IDs 1 and 2 should already exist
--   - Best used after generate-test-messages.sql to have messages to redistribute
--
-- Usage:
--   Run manually against a running MSSQL database:
--
--   docker exec -it mssql_server /opt/mssql-tools18/bin/sqlcmd \
--     -S localhost -U sa -P 'YourPassword' -d openfire -C \
--     -i /path/to/create-50-rooms.sql
--
-- =============================================================================

USE openfire;
GO

SET NOCOUNT ON;
GO

DECLARE @i INT = 3;
DECLARE @room_name VARCHAR(50);
DECLARE @creation_time CHAR(15);
DECLARE @base_time BIGINT = CAST(DATEDIFF(SECOND, '1970-01-01', GETDATE()) AS BIGINT) * 1000;

PRINT 'Creating additional MUC rooms...';
PRINT 'Current time (ms): ' + CAST(@base_time AS VARCHAR(20));

-- Create rooms 3 through 50 (48 additional rooms)
WHILE @i <= 50
BEGIN
    SET @room_name = 'muc' + CAST(@i AS VARCHAR(10));
    SET @creation_time = RIGHT(REPLICATE('0', 15) + CAST(@base_time - (@i * 1000) AS VARCHAR(15)), 15);

    INSERT INTO ofMucRoom (
        serviceID, roomID, creationDate, modificationDate, name, naturalName, description,
        lockedDate, emptyDate, canChangeSubject, maxUsers, publicRoom, moderated,
        membersOnly, canInvite, roomPassword, canDiscoverJID, logEnabled,
        retireOnDeletion, preserveHistOnDel, subject, rolesToBroadcast,
        useReservedNick, canChangeNick, canRegister, allowpm, fmucEnabled,
        fmucOutboundNode, fmucOutboundMode, fmucInboundNodes
    )
    VALUES (
        1,                      -- serviceID
        @i,                     -- roomID
        @creation_time,         -- creationDate
        @creation_time,         -- modificationDate
        @room_name,             -- name
        @room_name,             -- naturalName
        @room_name,             -- description
        '000000000000000',      -- lockedDate (not locked)
        @creation_time,         -- emptyDate
        0,                      -- canChangeSubject
        30,                     -- maxUsers
        1,                      -- publicRoom
        0,                      -- moderated
        0,                      -- membersOnly
        0,                      -- canInvite
        NULL,                   -- roomPassword
        1,                      -- canDiscoverJID
        1,                      -- logEnabled
        0,                      -- retireOnDeletion
        1,                      -- preserveHistOnDel
        '',                     -- subject
        7,                      -- rolesToBroadcast
        0,                      -- useReservedNick
        1,                      -- canChangeNick
        1,                      -- canRegister
        0,                      -- allowpm
        0,                      -- fmucEnabled
        NULL,                   -- fmucOutboundNode
        NULL,                   -- fmucOutboundMode
        NULL                    -- fmucInboundNodes
    );

    IF @i % 10 = 0
    BEGIN
        PRINT 'Created room: ' + @room_name;
    END

    SET @i = @i + 1;
END

PRINT 'Room creation complete.';
GO

-- Now redistribute messages across all 50 rooms
-- This simulates a more realistic distribution where each room has messages
PRINT 'Redistributing messages across all 50 rooms...';

UPDATE ofMucConversationLog
SET roomID = (messageID % 50) + 1;

PRINT 'Message redistribution complete.';
GO

-- Verify
PRINT '';
PRINT '=== Verification ===';
SELECT 'Total rooms: ' + CAST(COUNT(*) AS VARCHAR(10)) AS result FROM ofMucRoom;
SELECT 'Total messages: ' + CAST(COUNT(*) AS VARCHAR(10)) AS result FROM ofMucConversationLog;
SELECT 'Messages per room (sample):' AS result;
SELECT TOP 10
    'Room ' + CAST(roomID AS VARCHAR(5)) + ': ' + CAST(COUNT(*) AS VARCHAR(10)) + ' messages' AS result
FROM ofMucConversationLog
GROUP BY roomID
ORDER BY roomID;
GO
