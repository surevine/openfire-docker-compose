-- MariaDB dump 10.19  Distrib 10.9.4-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: openfire
-- ------------------------------------------------------
-- Server version	10.9.4-MariaDB-log


--
-- Table structure for table `ofExtComponentConf`
--




CREATE TABLE `ofExtComponentConf` (
  `subdomain` varchar(255) NOT NULL,
  `wildcard` tinyint(4) NOT NULL,
  `secret` varchar(255) DEFAULT NULL,
  `permission` varchar(10) NOT NULL,
  PRIMARY KEY (`subdomain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofGroup`
--




CREATE TABLE `ofGroup` (
  `groupName` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`groupName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofGroupProp`
--




CREATE TABLE `ofGroupProp` (
  `groupName` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `propValue` text NOT NULL,
  PRIMARY KEY (`groupName`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofGroupUser`
--




CREATE TABLE `ofGroupUser` (
  `groupName` varchar(50) NOT NULL,
  `username` varchar(100) NOT NULL,
  `administrator` tinyint(4) NOT NULL,
  PRIMARY KEY (`groupName`,`username`,`administrator`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Table structure for table `ofID`
--




CREATE TABLE `ofID` (
  `idType` int(11) NOT NULL,
  `id` bigint(20) NOT NULL,
  PRIMARY KEY (`idType`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


INSERT INTO `ofID` VALUES
(18,1),
(19,1),
(23,6),
(25,12),
(26,2),
(27,51);

--
-- Table structure for table `ofMucAffiliation`
--




CREATE TABLE `ofMucAffiliation` (
  `roomID` bigint(20) NOT NULL,
  `jid` text NOT NULL,
  `affiliation` tinyint(4) NOT NULL,
  PRIMARY KEY (`roomID`,`jid`(70))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


INSERT INTO `ofMucAffiliation` VALUES
(1,'admin@xmpp.localhost.example',10),
(2,'admin@xmpp.localhost.example',10);

--
-- Table structure for table `ofMucConversationLog`
--




CREATE TABLE `ofMucConversationLog` (
  `roomID` bigint(20) NOT NULL,
  `messageID` bigint(20) NOT NULL,
  `sender` text NOT NULL,
  `nickname` varchar(255) DEFAULT NULL,
  `logTime` char(15) NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` text DEFAULT NULL,
  `stanza` text DEFAULT NULL,
  KEY `ofMucConversationLog_roomtime_idx` (`roomID`,`logTime`),
  KEY `ofMucConversationLog_time_idx` (`logTime`),
  KEY `ofMucConversationLog_msg_id` (`messageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofMucConversationLog`
--

INSERT INTO `ofMucConversationLog` VALUES
(1,1,'muc1@conference.xmpp.localhost.example',NULL,'001668898144605','',NULL,'<message type=\"groupchat\" from=\"muc1@conference.xmpp.localhost.example\" to=\"muc1@conference.xmpp.localhost.example\"><subject></subject></message>'),
(2,2,'muc2@conference.xmpp.localhost.example',NULL,'001668898266510','',NULL,'<message type=\"groupchat\" from=\"muc2@conference.xmpp.localhost.example\" to=\"muc2@conference.xmpp.localhost.example\"><subject></subject></message>');



--
-- Table structure for table `ofMucMember`
--


CREATE TABLE `ofMucMember` (
  `roomID` bigint(20) NOT NULL,
  `jid` text NOT NULL,
  `nickname` varchar(255) DEFAULT NULL,
  `firstName` varchar(100) DEFAULT NULL,
  `lastName` varchar(100) DEFAULT NULL,
  `url` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `faqentry` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`roomID`,`jid`(70))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofMucRoom`
--




CREATE TABLE `ofMucRoom` (
  `serviceID` bigint(20) NOT NULL,
  `roomID` bigint(20) NOT NULL,
  `creationDate` char(15) NOT NULL,
  `modificationDate` char(15) NOT NULL,
  `name` varchar(50) NOT NULL,
  `naturalName` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `lockedDate` char(15) NOT NULL,
  `emptyDate` char(15) DEFAULT NULL,
  `canChangeSubject` tinyint(4) NOT NULL,
  `maxUsers` int(11) NOT NULL,
  `publicRoom` tinyint(4) NOT NULL,
  `moderated` tinyint(4) NOT NULL,
  `membersOnly` tinyint(4) NOT NULL,
  `canInvite` tinyint(4) NOT NULL,
  `roomPassword` varchar(50) DEFAULT NULL,
  `canDiscoverJID` tinyint(4) NOT NULL,
  `logEnabled` tinyint(4) NOT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `rolesToBroadcast` tinyint(4) NOT NULL,
  `useReservedNick` tinyint(4) NOT NULL,
  `canChangeNick` tinyint(4) NOT NULL,
  `canRegister` tinyint(4) NOT NULL,
  `allowpm` tinyint(4) DEFAULT NULL,
  `fmucEnabled` tinyint(4) DEFAULT NULL,
  `fmucOutboundNode` varchar(255) DEFAULT NULL,
  `fmucOutboundMode` tinyint(4) DEFAULT NULL,
  `fmucInboundNodes` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`serviceID`,`name`),
  KEY `ofMucRoom_roomid_idx` (`roomID`),
  KEY `ofMucRoom_serviceid_idx` (`serviceID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofMucRoom`
--


INSERT INTO `ofMucRoom` VALUES
(1,1,'001668898144600','001668898144619','muc1','MUC One','First MUC Room','000000000000000','001668898144600',0,30,1,0,0,0,NULL,1,1,'',7,0,1,1,0,0,NULL,NULL,NULL),
(1,2,'001668898266509','001668898266510','muc2','MUC Two','Second MUC room','000000000000000','001668898266509',0,30,1,0,0,0,NULL,1,1,'',7,0,1,1,0,0,NULL,NULL,NULL);



--
-- Table structure for table `ofMucRoomProp`
--




CREATE TABLE `ofMucRoomProp` (
  `roomID` bigint(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `propValue` text NOT NULL,
  PRIMARY KEY (`roomID`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;




--
-- Table structure for table `ofMucService`
--




CREATE TABLE `ofMucService` (
  `serviceID` bigint(20) NOT NULL,
  `subdomain` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `isHidden` tinyint(4) NOT NULL,
  PRIMARY KEY (`subdomain`),
  KEY `ofMucService_serviceid_idx` (`serviceID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofMucService`
--



INSERT INTO `ofMucService` VALUES
(1,'conference',NULL,0);



--
-- Table structure for table `ofMucServiceProp`
--




CREATE TABLE `ofMucServiceProp` (
  `serviceID` bigint(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `propValue` text NOT NULL,
  PRIMARY KEY (`serviceID`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofMucServiceProp`
--






--
-- Table structure for table `ofOffline`
--




CREATE TABLE `ofOffline` (
  `username` varchar(64) NOT NULL,
  `messageID` bigint(20) NOT NULL,
  `creationDate` char(15) NOT NULL,
  `messageSize` int(11) NOT NULL,
  `stanza` text NOT NULL,
  PRIMARY KEY (`username`,`messageID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofOffline`
--






--
-- Table structure for table `ofPresence`
--




CREATE TABLE `ofPresence` (
  `username` varchar(64) NOT NULL,
  `offlinePresence` text DEFAULT NULL,
  `offlineDate` char(15) NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofPresence`
--






--
-- Table structure for table `ofPrivacyList`
--




CREATE TABLE `ofPrivacyList` (
  `username` varchar(64) NOT NULL,
  `name` varchar(100) NOT NULL,
  `isDefault` tinyint(4) NOT NULL,
  `list` text NOT NULL,
  PRIMARY KEY (`username`,`name`),
  KEY `ofPrivacyList_default_idx` (`username`,`isDefault`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofPrivacyList`
--






--
-- Table structure for table `ofProperty`
--




CREATE TABLE `ofProperty` (
  `name` varchar(100) NOT NULL,
  `propValue` text NOT NULL,
  `encrypted` int(11) DEFAULT NULL,
  `iv` char(24) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofProperty`
--



INSERT INTO `ofProperty` VALUES
('cache.MUCService\'conference\'Rooms.maxLifetime','-1',0,NULL),
('cache.MUCService\'conference\'Rooms.size','-1',0,NULL),
('cache.MUCService\'conference\'RoomStatistics.maxLifetime','-1',0,NULL),
('cache.MUCService\'conference\'RoomStatistics.size','-1',0,NULL),
('passwordKey','ZGUaqsUSz4fw13t',0,NULL),
('update.lastCheck','1668897795614',0,NULL),
('xmpp.domain','xmpp.localhost.example',0,NULL);



--
-- Table structure for table `ofPubsubAffiliation`
--




CREATE TABLE `ofPubsubAffiliation` (
  `serviceID` varchar(100) NOT NULL,
  `nodeID` varchar(100) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `affiliation` varchar(10) NOT NULL,
  PRIMARY KEY (`serviceID`,`nodeID`,`jid`(70))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofPubsubAffiliation`
--



INSERT INTO `ofPubsubAffiliation` VALUES
('pubsub','','xmpp.localhost.example','owner');



--
-- Table structure for table `ofPubsubDefaultConf`
--




CREATE TABLE `ofPubsubDefaultConf` (
  `serviceID` varchar(100) NOT NULL,
  `leaf` tinyint(4) NOT NULL,
  `deliverPayloads` tinyint(4) NOT NULL,
  `maxPayloadSize` int(11) NOT NULL,
  `persistItems` tinyint(4) NOT NULL,
  `maxItems` int(11) NOT NULL,
  `notifyConfigChanges` tinyint(4) NOT NULL,
  `notifyDelete` tinyint(4) NOT NULL,
  `notifyRetract` tinyint(4) NOT NULL,
  `presenceBased` tinyint(4) NOT NULL,
  `sendItemSubscribe` tinyint(4) NOT NULL,
  `publisherModel` varchar(15) NOT NULL,
  `subscriptionEnabled` tinyint(4) NOT NULL,
  `accessModel` varchar(10) NOT NULL,
  `language` varchar(255) DEFAULT NULL,
  `replyPolicy` varchar(15) DEFAULT NULL,
  `associationPolicy` varchar(15) NOT NULL,
  `maxLeafNodes` int(11) NOT NULL,
  PRIMARY KEY (`serviceID`,`leaf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofPubsubDefaultConf`
--



INSERT INTO `ofPubsubDefaultConf` VALUES
('pubsub',0,0,0,0,0,1,1,1,0,0,'publishers',1,'open','English',NULL,'all',-1),
('pubsub',1,1,10485760,0,1,1,1,1,0,1,'publishers',1,'open','English',NULL,'all',-1);



--
-- Table structure for table `ofPubsubItem`
--


CREATE TABLE `ofPubsubItem` (
  `serviceID` varchar(100) NOT NULL,
  `nodeID` varchar(100) NOT NULL,
  `id` varchar(100) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `creationDate` char(15) NOT NULL,
  `payload` mediumtext DEFAULT NULL,
  PRIMARY KEY (`serviceID`,`nodeID`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofPubsubNode`
--




CREATE TABLE `ofPubsubNode` (
  `serviceID` varchar(100) NOT NULL,
  `nodeID` varchar(100) NOT NULL,
  `leaf` tinyint(4) NOT NULL,
  `creationDate` char(15) NOT NULL,
  `modificationDate` char(15) NOT NULL,
  `parent` varchar(100) DEFAULT NULL,
  `deliverPayloads` tinyint(4) NOT NULL,
  `maxPayloadSize` int(11) DEFAULT NULL,
  `persistItems` tinyint(4) DEFAULT NULL,
  `maxItems` int(11) DEFAULT NULL,
  `notifyConfigChanges` tinyint(4) NOT NULL,
  `notifyDelete` tinyint(4) NOT NULL,
  `notifyRetract` tinyint(4) NOT NULL,
  `presenceBased` tinyint(4) NOT NULL,
  `sendItemSubscribe` tinyint(4) NOT NULL,
  `publisherModel` varchar(15) NOT NULL,
  `subscriptionEnabled` tinyint(4) NOT NULL,
  `configSubscription` tinyint(4) NOT NULL,
  `accessModel` varchar(10) NOT NULL,
  `payloadType` varchar(100) DEFAULT NULL,
  `bodyXSLT` varchar(100) DEFAULT NULL,
  `dataformXSLT` varchar(100) DEFAULT NULL,
  `creator` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `language` varchar(255) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `replyPolicy` varchar(15) DEFAULT NULL,
  `associationPolicy` varchar(15) DEFAULT NULL,
  `maxLeafNodes` int(11) DEFAULT NULL,
  PRIMARY KEY (`serviceID`,`nodeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofPubsubNode`
--



INSERT INTO `ofPubsubNode` VALUES
('pubsub','',0,'001668897760143','001668897760143',NULL,0,0,0,0,1,1,1,0,0,'publishers',1,0,'open','','','','xmpp.localhost.example','','English','',NULL,'all',-1);



--
-- Table structure for table `ofPubsubNodeGroups`
--




CREATE TABLE `ofPubsubNodeGroups` (
  `serviceID` varchar(100) NOT NULL,
  `nodeID` varchar(100) NOT NULL,
  `rosterGroup` varchar(100) NOT NULL,
  KEY `ofPubsubNodeGroups_idx` (`serviceID`,`nodeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofPubsubNodeJIDs`
--




CREATE TABLE `ofPubsubNodeJIDs` (
  `serviceID` varchar(100) NOT NULL,
  `nodeID` varchar(100) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `associationType` varchar(20) NOT NULL,
  PRIMARY KEY (`serviceID`,`nodeID`,`jid`(70))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofPubsubSubscription`
--




CREATE TABLE `ofPubsubSubscription` (
  `serviceID` varchar(100) NOT NULL,
  `nodeID` varchar(100) NOT NULL,
  `id` varchar(100) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `state` varchar(15) NOT NULL,
  `deliver` tinyint(4) NOT NULL,
  `digest` tinyint(4) NOT NULL,
  `digest_frequency` int(11) NOT NULL,
  `expire` char(15) DEFAULT NULL,
  `includeBody` tinyint(4) NOT NULL,
  `showValues` varchar(30) DEFAULT NULL,
  `subscriptionType` varchar(10) NOT NULL,
  `subscriptionDepth` tinyint(4) NOT NULL,
  `keyword` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`serviceID`,`nodeID`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;




--
-- Table structure for table `ofRemoteServerConf`
--




CREATE TABLE `ofRemoteServerConf` (
  `xmppDomain` varchar(255) NOT NULL,
  `remotePort` int(11) DEFAULT NULL,
  `permission` varchar(10) NOT NULL,
  PRIMARY KEY (`xmppDomain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofRoster`
--


CREATE TABLE `ofRoster` (
  `rosterID` bigint(20) NOT NULL,
  `username` varchar(64) NOT NULL,
  `jid` varchar(1024) NOT NULL,
  `sub` tinyint(4) NOT NULL,
  `ask` tinyint(4) NOT NULL,
  `recv` tinyint(4) NOT NULL,
  `nick` varchar(255) DEFAULT NULL,
  `stanza` text DEFAULT NULL,
  PRIMARY KEY (`rosterID`),
  KEY `ofRoster_unameid_idx` (`username`),
  KEY `ofRoster_jid_idx` (`jid`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;



--
-- Table structure for table `ofRosterGroups`
--




CREATE TABLE `ofRosterGroups` (
  `rosterID` bigint(20) NOT NULL,
  `rank` tinyint(4) NOT NULL,
  `groupName` varchar(255) NOT NULL,
  PRIMARY KEY (`rosterID`,`rank`),
  KEY `ofRosterGroup_rosterid_idx` (`rosterID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;




--
-- Table structure for table `ofSASLAuthorized`
--




CREATE TABLE `ofSASLAuthorized` (
  `username` varchar(64) NOT NULL,
  `principal` text NOT NULL,
  PRIMARY KEY (`username`,`principal`(200))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;




--
-- Table structure for table `ofSecurityAuditLog`
--




CREATE TABLE `ofSecurityAuditLog` (
  `msgID` bigint(20) NOT NULL,
  `username` varchar(64) NOT NULL,
  `entryStamp` bigint(20) NOT NULL,
  `summary` varchar(255) NOT NULL,
  `node` varchar(255) NOT NULL,
  `details` text DEFAULT NULL,
  PRIMARY KEY (`msgID`),
  KEY `ofSecurityAuditLog_tstamp_idx` (`entryStamp`),
  KEY `ofSecurityAuditLog_uname_idx` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofSecurityAuditLog`
--



INSERT INTO `ofSecurityAuditLog` VALUES
(1,'admin',1668897797130,'Successful admin console login attempt','xmpp1.localhost.example','The user logged in successfully to the admin console from address 172.60.0.1. '),
(2,'admin',1668898061969,'created new user user1','xmpp1.localhost.example','name = User One, email = null, admin = false'),
(3,'admin',1668898061978,'added group member to null','xmpp1.localhost.example','username = user1'),
(4,'admin',1668898071126,'created new user user2','xmpp1.localhost.example','name = User Two, email = null, admin = false'),
(5,'admin',1668898071136,'added group member to null','xmpp1.localhost.example','username = user2'),
(6,'admin',1668898080692,'created new user user3','xmpp1.localhost.example','name = User Three, email = null, admin = false'),
(7,'admin',1668898080700,'added group member to null','xmpp1.localhost.example','username = user3'),
(8,'admin',1668898144638,'created new MUC room muc1','xmpp1.localhost.example','subject = \nroomdesc = First MUC Room\nroomname = MUC One\nmaxusers = 30'),
(9,'admin',1668898266545,'created new MUC room muc2','xmpp1.localhost.example','subject = \nroomdesc = Second MUC room\nroomname = MUC Two\nmaxusers = 30'),
(10,'admin',1668898435466,'Updated server property xmpp.domain','xmpp1.localhost.example','Property created with value \'xmpp.localhost.example\'');



--
-- Table structure for table `ofUser`
--




CREATE TABLE `ofUser` (
  `username` varchar(64) NOT NULL,
  `storedKey` varchar(32) DEFAULT NULL,
  `serverKey` varchar(32) DEFAULT NULL,
  `salt` varchar(32) DEFAULT NULL,
  `iterations` int(11) DEFAULT NULL,
  `plainPassword` varchar(32) DEFAULT NULL,
  `encryptedPassword` varchar(255) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `creationDate` char(15) NOT NULL,
  `modificationDate` char(15) NOT NULL,
  PRIMARY KEY (`username`),
  KEY `ofUser_cDate_idx` (`creationDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofUser`
--



INSERT INTO `ofUser` VALUES
('admin','JE6LyPcQZdChBNNeM0M7snT1dXM=','31Otc5MIhsPspMdeXiJ94kQ9FZA=','JDnaIaXxR5/ga4cmvq7osEM2mGfgi/nj',4096,NULL,'a49c592969e790ec55cf12052e61cf825c3d8280b0e17617','Administrator','admin@example.com','001668896628386','0'),
('user1','OvLMqePOH2WjgO0YiBGcCyu1Too=','nb+gNEZpy5B02vSfz6mz6daVnW0=','3n8axfTJ11fg4l5FdicKpEsMNJO7iDD1',4096,NULL,'e92627b0960a7cfa4fb4abd734b2b49f7f3e3beb4f67607a3a6373b54e095fa0','User One',NULL,'001668898061935','001668898061935'),
('user2','feTCBDi6/ax6qnGBIb3w0zDZUMY=','x6HLyC4wd0DbEtYf+4Glv2mUFUE=','4bAfMLWYChBEQ0WtM0h1bBHVet/qF0eT',4096,NULL,'246b445922dbd94fda5ff1c3da4f6d61efbdf65ff4541735b926d30b92c89534','User Two',NULL,'001668898071105','001668898071105'),
('user3','HL/+RMY4RRvbvZ2Cbn0zrGY0GSU=','B6tiBNMyTkUjLsLqeaZ/C3nU3hI=','erfKR7jcUT1eeO94EWJjKDAmyfD0C9d8',4096,NULL,'2e64a59c37f3ff01dbd95274c84695af84d309e42f6b5e676762a056a503416e','User Three',NULL,'001668898080670','001668898080670');



--
-- Table structure for table `ofUserFlag`
--


CREATE TABLE `ofUserFlag` (
  `username` varchar(64) NOT NULL,
  `name` varchar(100) NOT NULL,
  `startTime` char(15) DEFAULT NULL,
  `endTime` char(15) DEFAULT NULL,
  PRIMARY KEY (`username`,`name`),
  KEY `ofUserFlag_sTime_idx` (`startTime`),
  KEY `ofUserFlag_eTime_idx` (`endTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofUserFlag`
--






--
-- Table structure for table `ofUserProp`
--




CREATE TABLE `ofUserProp` (
  `username` varchar(64) NOT NULL,
  `name` varchar(100) NOT NULL,
  `propValue` text NOT NULL,
  PRIMARY KEY (`username`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofUserProp`
--



INSERT INTO `ofUserProp` VALUES
('admin','console.rows_per_page','/muc-room-summary.jsp=25,/session-summary.jsp=25,/pubsub-node-summary.jsp=25,/server-properties.jsp=25');



--
-- Table structure for table `ofVCard`
--




CREATE TABLE `ofVCard` (
  `username` varchar(64) NOT NULL,
  `vcard` mediumtext NOT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofVCard`
--






--
-- Table structure for table `ofVersion`
--




CREATE TABLE `ofVersion` (
  `name` varchar(50) NOT NULL,
  `version` int(11) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


--
-- Dumping data for table `ofVersion`
--



INSERT INTO `ofVersion` VALUES
('openfire',34);












-- Dump completed on 2022-11-19 22:56:21
