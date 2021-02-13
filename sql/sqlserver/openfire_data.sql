-- This is a hand-fettled script, adding data as per a v30 database structure

insert [ofProperty] ([name],[propValue],[encrypted],[iv])
select 'passwordKey','c3rlwT7ijt1TqK6',0,NULL UNION ALL
select 'provider.admin.className','org.jivesoftware.openfire.admin.DefaultAdminProvider',0,NULL UNION ALL
select 'provider.auth.className','org.jivesoftware.openfire.auth.DefaultAuthProvider',0,NULL UNION ALL
select 'provider.group.className','org.jivesoftware.openfire.group.DefaultGroupProvider',0,NULL UNION ALL
select 'provider.lockout.className','org.jivesoftware.openfire.lockout.DefaultLockOutProvider',0,NULL UNION ALL
select 'provider.securityAudit.className','org.jivesoftware.openfire.security.DefaultSecurityAuditProvider',0,NULL UNION ALL
select 'provider.user.className','org.jivesoftware.openfire.user.DefaultUserProvider',0,NULL UNION ALL
select 'provider.vcard.className','org.jivesoftware.openfire.vcard.DefaultVCardProvider',0,NULL UNION ALL
select 'update.lastCheck','1613237450302',0,NULL UNION ALL
select 'xmpp.auth.anonymous','false',0,NULL UNION ALL
select 'xmpp.domain','xmpp.localhost.example',0,NULL UNION ALL
select 'xmpp.socket.ssl.active','true',0,NULL;


insert [ofPubsubDefaultConf] ([serviceID],[leaf],[deliverPayloads],[maxPayloadSize],[persistItems],[maxItems],[notifyConfigChanges],[notifyDelete],[notifyRetract],[presenceBased],[sendItemSubscribe],[publisherModel],[subscriptionEnabled],[accessModel],[language],[replyPolicy],[associationPolicy],[maxLeafNodes])
select 'pubsub',0,0,0,0,0,1,1,1,0,0,'publishers',1,'open','English',NULL,'all',-1 UNION ALL
select 'pubsub',1,1,10485760,0,1,1,1,1,0,1,'publishers',1,'open','English',NULL,'all',-1;

insert [ofPubsubNode] ([serviceID],[nodeID],[leaf],[creationDate],[modificationDate],[parent],[deliverPayloads],[maxPayloadSize],[persistItems],[maxItems],[notifyConfigChanges],[notifyDelete],[notifyRetract],[presenceBased],[sendItemSubscribe],[publisherModel],[subscriptionEnabled],[configSubscription],[accessModel],[payloadType],[bodyXSLT],[dataformXSLT],[creator],[description],[language],[name],[replyPolicy],[associationPolicy],[maxLeafNodes])
select 'pubsub','',0,'001613237414897','001613237414897',NULL,0,0,0,0,1,1,1,0,0,'publishers',1,0,'open','','','','xmpp.localhost.example','','English','',NULL,'all',-1;

insert [ofPubsubAffiliation] ([serviceID],[nodeID],[jid],[affiliation])
select 'pubsub','','xmpp.localhost.example','owner';

insert [ofSecurityAuditLog] ([msgID],[username],[entryStamp],[summary],[node],[details])
select 1,'admin',1613237419902,'Successful admin console login attempt','xmpp.localhost.example','The user logged in successfully to the admin console from address 172.70.0.1. ' UNION ALL
select 2,'admin',1613238674561,'created new user user1','xmpp.localhost.example','name = null, email = null, admin = false' UNION ALL
select 3,'admin',1613238682953,'created new user user2','xmpp.localhost.example','name = null, email = null, admin = false' UNION ALL
select 4,'admin',1613238689939,'created new user user3','xmpp.localhost.example','name = null, email = null, admin = false';

insert [ofUser] ([username],[storedKey],[serverKey],[salt],[iterations],[plainPassword],[encryptedPassword],[name],[email],[creationDate],[modificationDate])
--select 'admin','4dhG3yvLGEUh0MFXReJjQapiJmg=','+ppXcL2tMyEAp/FpWCDRIBYZwYU=','0YV3ub/KtC1lsl3JrFC3LqMoeQDDZeyi',4096,NULL,'dd79bd6a56a8aeb4b41231a6d3f3b1c03c4693b79d0835ba','Administrator','admin@example.com','001613237412842','0              ' UNION ALL
select 'user1','3J7uvQQgUYbwcfCq1NdwJdg/OEY=','nBA5c2QxabhlkBXYjVWNdFIOeQ4=','Whx8l40WIZDqspBFAV1iKjukhyiv47zL',4096,NULL,'1c6e8b14c538038f959733e7ec89ef13c65a7d5a85fcf8f89b2b881ffadbcd21',NULL,NULL,'001613238674533','001613238674533' UNION ALL
select 'user2','Sh3vxOxEEYRrKwC8tjZRoeRY/YE=','qsAj/TFx0oyT3ik+paR8SJ/HqUY=','V9NJrs/aWWB1f0ljeAzeu2ya5ygS94kc',4096,NULL,'1590781e96b533cd1377a419ffce58b1c28368e54972a9ce9f311728b43e6f3d',NULL,NULL,'001613238682884','001613238682884' UNION ALL
select 'user3','ek+kMBQ1oGEvyZalK/UnTuC7Xro=','zWuQN3uWxyaIB7LUuJegvQe9Vmg=','m7vVvrcAEM22p4sxzUYfFRC2BxlzOI2Y',4096,NULL,'5f1678df99186bb99640b213fb4734c81c967a2114971cbc5c02c7466415d24b',NULL,NULL,'001613238689918','001613238689918';

insert [ofMucRoom] ([serviceID],[roomID],[creationDate],[modificationDate],[name],[naturalName],[description],[lockedDate],[emptyDate],[canChangeSubject],[maxUsers],[publicRoom],[moderated],[membersOnly],[canInvite],[roomPassword],[canDiscoverJID],[logEnabled],[subject],[rolesToBroadcast],[useReservedNick],[canChangeNick],[canRegister],[allowpm])
select 1,1,'001613248823513','001613248823537','muc1','MUC One','First MUC Room','000000000000000',NULL,0,30,1,0,0,0,NULL,1,1,'',7,0,1,1,0;

insert [ofMucAffiliation] ([roomID],[jid],[affiliation])
select 1,'admin@xmpp.localhost.example',10;

insert [ofMucConversationLog] ([roomID],[messageID],[sender],[nickname],[logTime],[subject],[body],[stanza])
select 1,1,'muc1@conference.xmpp.localhost.example',NULL,'001613248823526','',NULL,'<message type="groupchat" from="muc1@conference.xmpp.localhost.example" to="muc1@conference.xmpp.localhost.example"><subject></subject></message>';

--insert [ofVersion] ([name],[version])
--select 'openfire',30;