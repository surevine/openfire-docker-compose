--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.17
-- Dumped by pg_dump version 9.6.17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ofextcomponentconf; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofextcomponentconf (
    subdomain character varying(255) NOT NULL,
    wildcard integer NOT NULL,
    secret character varying(255),
    permission character varying(10) NOT NULL
);


ALTER TABLE public.ofextcomponentconf OWNER TO openfire;

--
-- Name: ofgroup; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofgroup (
    groupname character varying(50) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.ofgroup OWNER TO openfire;

--
-- Name: ofgroupprop; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofgroupprop (
    groupname character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    propvalue text NOT NULL
);


ALTER TABLE public.ofgroupprop OWNER TO openfire;

--
-- Name: ofgroupuser; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofgroupuser (
    groupname character varying(50) NOT NULL,
    username character varying(100) NOT NULL,
    administrator integer NOT NULL
);


ALTER TABLE public.ofgroupuser OWNER TO openfire;

--
-- Name: ofid; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofid (
    idtype integer NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.ofid OWNER TO openfire;

--
-- Name: ofmucaffiliation; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofmucaffiliation (
    roomid integer NOT NULL,
    jid character varying(1024) NOT NULL,
    affiliation integer NOT NULL
);


ALTER TABLE public.ofmucaffiliation OWNER TO openfire;

--
-- Name: ofmucconversationlog; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofmucconversationlog (
    roomid integer NOT NULL,
    messageid integer NOT NULL,
    sender character varying(1024) NOT NULL,
    nickname character varying(255),
    logtime character(15) NOT NULL,
    subject character varying(255),
    body text,
    stanza text
);


ALTER TABLE public.ofmucconversationlog OWNER TO openfire;

--
-- Name: ofmucmember; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofmucmember (
    roomid integer NOT NULL,
    jid character varying(1024) NOT NULL,
    nickname character varying(255),
    firstname character varying(100),
    lastname character varying(100),
    url character varying(100),
    email character varying(100),
    faqentry character varying(100)
);


ALTER TABLE public.ofmucmember OWNER TO openfire;

--
-- Name: ofmucroom; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofmucroom (
    serviceid integer NOT NULL,
    roomid integer NOT NULL,
    creationdate character(15) NOT NULL,
    modificationdate character(15) NOT NULL,
    name character varying(50) NOT NULL,
    naturalname character varying(255) NOT NULL,
    description character varying(255),
    lockeddate character(15) NOT NULL,
    emptydate character(15),
    canchangesubject integer NOT NULL,
    maxusers integer NOT NULL,
    publicroom integer NOT NULL,
    moderated integer NOT NULL,
    membersonly integer NOT NULL,
    caninvite integer NOT NULL,
    roompassword character varying(50),
    candiscoverjid integer NOT NULL,
    logenabled integer NOT NULL,
    subject character varying(100),
    rolestobroadcast integer NOT NULL,
    usereservednick integer NOT NULL,
    canchangenick integer NOT NULL,
    canregister integer NOT NULL,
    allowpm integer,
    fmucEnabled integer,
    fmucOutboundNode text,
    fmucOutboundMode integer,
    fmucInboundNodes text
);


ALTER TABLE public.ofmucroom OWNER TO openfire;

--
-- Name: ofmucroomprop; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofmucroomprop (
    roomid integer NOT NULL,
    name character varying(100) NOT NULL,
    propvalue text NOT NULL
);


ALTER TABLE public.ofmucroomprop OWNER TO openfire;

--
-- Name: ofmucservice; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofmucservice (
    serviceid integer NOT NULL,
    subdomain character varying(255) NOT NULL,
    description character varying(255),
    ishidden integer NOT NULL
);


ALTER TABLE public.ofmucservice OWNER TO openfire;

--
-- Name: ofmucserviceprop; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofmucserviceprop (
    serviceid integer NOT NULL,
    name character varying(100) NOT NULL,
    propvalue text NOT NULL
);


ALTER TABLE public.ofmucserviceprop OWNER TO openfire;

--
-- Name: ofoffline; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofoffline (
    username character varying(64) NOT NULL,
    messageid integer NOT NULL,
    creationdate character(15) NOT NULL,
    messagesize integer NOT NULL,
    stanza text NOT NULL
);


ALTER TABLE public.ofoffline OWNER TO openfire;

--
-- Name: ofpresence; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpresence (
    username character varying(64) NOT NULL,
    offlinepresence text,
    offlinedate character varying(15) NOT NULL
);


ALTER TABLE public.ofpresence OWNER TO openfire;

--
-- Name: ofprivacylist; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofprivacylist (
    username character varying(64) NOT NULL,
    name character varying(100) NOT NULL,
    isdefault integer NOT NULL,
    list text NOT NULL
);


ALTER TABLE public.ofprivacylist OWNER TO openfire;

--
-- Name: ofproperty; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofproperty (
    name character varying(100) NOT NULL,
    propvalue character varying(4000) NOT NULL,
    encrypted integer,
    iv character(24)
);


ALTER TABLE public.ofproperty OWNER TO openfire;

--
-- Name: ofpubsubaffiliation; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpubsubaffiliation (
    serviceid character varying(100) NOT NULL,
    nodeid character varying(100) NOT NULL,
    jid character varying(1024) NOT NULL,
    affiliation character varying(10) NOT NULL
);


ALTER TABLE public.ofpubsubaffiliation OWNER TO openfire;

--
-- Name: ofpubsubdefaultconf; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpubsubdefaultconf (
    serviceid character varying(100) NOT NULL,
    leaf integer NOT NULL,
    deliverpayloads integer NOT NULL,
    maxpayloadsize integer NOT NULL,
    persistitems integer NOT NULL,
    maxitems integer NOT NULL,
    notifyconfigchanges integer NOT NULL,
    notifydelete integer NOT NULL,
    notifyretract integer NOT NULL,
    presencebased integer NOT NULL,
    senditemsubscribe integer NOT NULL,
    publishermodel character varying(15) NOT NULL,
    subscriptionenabled integer NOT NULL,
    accessmodel character varying(10) NOT NULL,
    language character varying(255),
    replypolicy character varying(15),
    associationpolicy character varying(15) NOT NULL,
    maxleafnodes integer NOT NULL
);


ALTER TABLE public.ofpubsubdefaultconf OWNER TO openfire;

--
-- Name: ofpubsubitem; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpubsubitem (
    serviceid character varying(100) NOT NULL,
    nodeid character varying(100) NOT NULL,
    id character varying(100) NOT NULL,
    jid character varying(1024) NOT NULL,
    creationdate character(15) NOT NULL,
    payload text
);


ALTER TABLE public.ofpubsubitem OWNER TO openfire;

--
-- Name: ofpubsubnode; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpubsubnode (
    serviceid character varying(100) NOT NULL,
    nodeid character varying(100) NOT NULL,
    leaf integer NOT NULL,
    creationdate character(15) NOT NULL,
    modificationdate character(15) NOT NULL,
    parent character varying(100),
    deliverpayloads integer NOT NULL,
    maxpayloadsize integer,
    persistitems integer,
    maxitems integer,
    notifyconfigchanges integer NOT NULL,
    notifydelete integer NOT NULL,
    notifyretract integer NOT NULL,
    presencebased integer NOT NULL,
    senditemsubscribe integer NOT NULL,
    publishermodel character varying(15) NOT NULL,
    subscriptionenabled integer NOT NULL,
    configsubscription integer NOT NULL,
    accessmodel character varying(10) NOT NULL,
    payloadtype character varying(100),
    bodyxslt character varying(100),
    dataformxslt character varying(100),
    creator character varying(1024) NOT NULL,
    description character varying(255),
    language character varying(255),
    name character varying(50),
    replypolicy character varying(15),
    associationpolicy character varying(15),
    maxleafnodes integer
);


ALTER TABLE public.ofpubsubnode OWNER TO openfire;

--
-- Name: ofpubsubnodegroups; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpubsubnodegroups (
    serviceid character varying(100) NOT NULL,
    nodeid character varying(100) NOT NULL,
    rostergroup character varying(100) NOT NULL
);


ALTER TABLE public.ofpubsubnodegroups OWNER TO openfire;

--
-- Name: ofpubsubnodejids; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpubsubnodejids (
    serviceid character varying(100) NOT NULL,
    nodeid character varying(100) NOT NULL,
    jid character varying(1024) NOT NULL,
    associationtype character varying(20) NOT NULL
);


ALTER TABLE public.ofpubsubnodejids OWNER TO openfire;

--
-- Name: ofpubsubsubscription; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofpubsubsubscription (
    serviceid character varying(100) NOT NULL,
    nodeid character varying(100) NOT NULL,
    id character varying(100) NOT NULL,
    jid character varying(1024) NOT NULL,
    owner character varying(1024) NOT NULL,
    state character varying(15) NOT NULL,
    deliver integer NOT NULL,
    digest integer NOT NULL,
    digest_frequency integer NOT NULL,
    expire character(15),
    includebody integer NOT NULL,
    showvalues character varying(30) NOT NULL,
    subscriptiontype character varying(10) NOT NULL,
    subscriptiondepth integer NOT NULL,
    keyword character varying(200)
);


ALTER TABLE public.ofpubsubsubscription OWNER TO openfire;

--
-- Name: ofremoteserverconf; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofremoteserverconf (
    xmppdomain character varying(255) NOT NULL,
    remoteport integer,
    permission character varying(10) NOT NULL
);


ALTER TABLE public.ofremoteserverconf OWNER TO openfire;

--
-- Name: ofroster; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofroster (
    rosterid integer NOT NULL,
    username character varying(64) NOT NULL,
    jid character varying(1024) NOT NULL,
    sub integer NOT NULL,
    ask integer NOT NULL,
    recv integer NOT NULL,
    nick character varying(255)
);


ALTER TABLE public.ofroster OWNER TO openfire;

--
-- Name: ofrostergroups; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofrostergroups (
    rosterid integer NOT NULL,
    rank integer NOT NULL,
    groupname character varying(255) NOT NULL
);


ALTER TABLE public.ofrostergroups OWNER TO openfire;

--
-- Name: ofsaslauthorized; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofsaslauthorized (
    username character varying(64) NOT NULL,
    principal character varying(4000) NOT NULL
);


ALTER TABLE public.ofsaslauthorized OWNER TO openfire;

--
-- Name: ofsecurityauditlog; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofsecurityauditlog (
    msgid integer NOT NULL,
    username character varying(64) NOT NULL,
    entrystamp bigint NOT NULL,
    summary character varying(255) NOT NULL,
    node character varying(255) NOT NULL,
    details text
);


ALTER TABLE public.ofsecurityauditlog OWNER TO openfire;

--
-- Name: ofuser; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofuser (
    username character varying(64) NOT NULL,
    storedkey character varying(32),
    serverkey character varying(32),
    salt character varying(32),
    iterations integer,
    plainpassword character varying(32),
    encryptedpassword character varying(255),
    name character varying(100),
    email character varying(100),
    creationdate character(15) NOT NULL,
    modificationdate character(15) NOT NULL
);


ALTER TABLE public.ofuser OWNER TO openfire;

--
-- Name: ofuserflag; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofuserflag (
    username character varying(64) NOT NULL,
    name character varying(100) NOT NULL,
    starttime character(15),
    endtime character(15)
);


ALTER TABLE public.ofuserflag OWNER TO openfire;

--
-- Name: ofuserprop; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofuserprop (
    username character varying(64) NOT NULL,
    name character varying(100) NOT NULL,
    propvalue text NOT NULL
);


ALTER TABLE public.ofuserprop OWNER TO openfire;

--
-- Name: ofvcard; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofvcard (
    username character varying(64) NOT NULL,
    vcard text NOT NULL
);


ALTER TABLE public.ofvcard OWNER TO openfire;

--
-- Name: ofversion; Type: TABLE; Schema: public; Owner: openfire
--

CREATE TABLE public.ofversion (
    name character varying(50) NOT NULL,
    version integer NOT NULL
);


ALTER TABLE public.ofversion OWNER TO openfire;

--
-- Data for Name: ofextcomponentconf; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofextcomponentconf (subdomain, wildcard, secret, permission) FROM stdin;
\.


--
-- Data for Name: ofgroup; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofgroup (groupname, description) FROM stdin;
\.


--
-- Data for Name: ofgroupprop; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofgroupprop (groupname, name, propvalue) FROM stdin;
\.


--
-- Data for Name: ofgroupuser; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofgroupuser (groupname, username, administrator) FROM stdin;
\.


--
-- Data for Name: ofid; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofid (idtype, id) FROM stdin;
18	1
19	1
26	2
23	6
27	51
25	6
\.


--
-- Data for Name: ofmucaffiliation; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofmucaffiliation (roomid, jid, affiliation) FROM stdin;
1	admin@xmpp1.localhost.example	10
2	admin@xmpp1.localhost.example	10
\.


--
-- Data for Name: ofmucconversationlog; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofmucconversationlog (roomid, messageid, sender, nickname, logtime, subject, body, stanza) FROM stdin;
1	1	muc1@conference.xmpp1.localhost.example	\N	001590673128003		\N	<message type="groupchat" from="muc1@conference.xmpp1.localhost.example" to="muc1@conference.xmpp1.localhost.example"><subject></subject></message>
2	2	muc2@conference.xmpp1.localhost.example	\N	001590673151896		\N	<message type="groupchat" from="muc2@conference.xmpp1.localhost.example" to="muc2@conference.xmpp1.localhost.example"><subject></subject></message>
\.


--
-- Data for Name: ofmucmember; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofmucmember (roomid, jid, nickname, firstname, lastname, url, email, faqentry) FROM stdin;
\.


--
-- Data for Name: ofmucroom; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofmucroom (serviceid, roomid, creationdate, modificationdate, name, naturalname, description, lockeddate, emptydate, canchangesubject, maxusers, publicroom, moderated, membersonly, caninvite, roompassword, candiscoverjid, logenabled, subject, rolestobroadcast, usereservednick, canchangenick, canregister, allowpm, fmucEnabled, fmucOutboundNode, fmucOutboundMode, fmucInboundNodes) FROM stdin;
1	1	001590673127997	001590673128025	muc1	MUC One	First MUC room	000000000000000	\N	0	30	1	0	0	0	\N	0	1		7	0	1	1	0	0	\N	\N	\N
1	2	001590673151895	001590673151897	muc2	MUC Two	Second MUC room	000000000000000	\N	0	30	1	0	0	0	\N	0	1		7	0	1	1	0	0	\N	\N	\N
\.


--
-- Data for Name: ofmucroomprop; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofmucroomprop (roomid, name, propvalue) FROM stdin;
\.


--
-- Data for Name: ofmucservice; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofmucservice (serviceid, subdomain, description, ishidden) FROM stdin;
1	conference	\N	0
\.


--
-- Data for Name: ofmucserviceprop; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofmucserviceprop (serviceid, name, propvalue) FROM stdin;
\.


--
-- Data for Name: ofoffline; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofoffline (username, messageid, creationdate, messagesize, stanza) FROM stdin;
\.


--
-- Data for Name: ofpresence; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpresence (username, offlinepresence, offlinedate) FROM stdin;
\.


--
-- Data for Name: ofprivacylist; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofprivacylist (username, name, isdefault, list) FROM stdin;
\.


--
-- Data for Name: ofproperty; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofproperty (name, propvalue, encrypted, iv) FROM stdin;
user.scramHashedPasswordOnly	true	0	\N
xmpp.socket.ssl.active	true	0	\N
provider.admin.className	org.jivesoftware.openfire.admin.DefaultAdminProvider	0	\N
xmpp.domain	xmpp1.localhost.example	0	\N
xmpp.auth.anonymous	false	0	\N
provider.auth.className	org.jivesoftware.openfire.auth.DefaultAuthProvider	0	\N
provider.lockout.className	org.jivesoftware.openfire.lockout.DefaultLockOutProvider	0	\N
provider.group.className	org.jivesoftware.openfire.group.DefaultGroupProvider	0	\N
provider.vcard.className	org.jivesoftware.openfire.vcard.DefaultVCardProvider	0	\N
provider.securityAudit.className	org.jivesoftware.openfire.security.DefaultSecurityAuditProvider	0	\N
provider.user.className	org.jivesoftware.openfire.user.DefaultUserProvider	0	\N
update.lastCheck	1590672970635	0	\N
dnsutil.dnsOverride	{xmpp3.localhost.example,172.50.0.150:5269}	0	\N
\.


--
-- Data for Name: ofpubsubaffiliation; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpubsubaffiliation (serviceid, nodeid, jid, affiliation) FROM stdin;
\.


--
-- Data for Name: ofpubsubdefaultconf; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpubsubdefaultconf (serviceid, leaf, deliverpayloads, maxpayloadsize, persistitems, maxitems, notifyconfigchanges, notifydelete, notifyretract, presencebased, senditemsubscribe, publishermodel, subscriptionenabled, accessmodel, language, replypolicy, associationpolicy, maxleafnodes) FROM stdin;
pubsub	1	1	10485760	0	1	1	1	1	0	1	publishers	1	open	English	\N	all	-1
pubsub	0	0	0	0	0	1	1	1	0	0	publishers	1	open	English	\N	all	-1
\.


--
-- Data for Name: ofpubsubitem; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpubsubitem (serviceid, nodeid, id, jid, creationdate, payload) FROM stdin;
\.


--
-- Data for Name: ofpubsubnode; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpubsubnode (serviceid, nodeid, leaf, creationdate, modificationdate, parent, deliverpayloads, maxpayloadsize, persistitems, maxitems, notifyconfigchanges, notifydelete, notifyretract, presencebased, senditemsubscribe, publishermodel, subscriptionenabled, configsubscription, accessmodel, payloadtype, bodyxslt, dataformxslt, creator, description, language, name, replypolicy, associationpolicy, maxleafnodes) FROM stdin;
\.


--
-- Data for Name: ofpubsubnodegroups; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpubsubnodegroups (serviceid, nodeid, rostergroup) FROM stdin;
\.


--
-- Data for Name: ofpubsubnodejids; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpubsubnodejids (serviceid, nodeid, jid, associationtype) FROM stdin;
\.


--
-- Data for Name: ofpubsubsubscription; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofpubsubsubscription (serviceid, nodeid, id, jid, owner, state, deliver, digest, digest_frequency, expire, includebody, showvalues, subscriptiontype, subscriptiondepth, keyword) FROM stdin;
\.


--
-- Data for Name: ofremoteserverconf; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofremoteserverconf (xmppdomain, remoteport, permission) FROM stdin;
\.


--
-- Data for Name: ofroster; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofroster (rosterid, username, jid, sub, ask, recv, nick) FROM stdin;
\.


--
-- Data for Name: ofrostergroups; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofrostergroups (rosterid, rank, groupname) FROM stdin;
\.


--
-- Data for Name: ofsaslauthorized; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofsaslauthorized (username, principal) FROM stdin;
\.


--
-- Data for Name: ofsecurityauditlog; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofsecurityauditlog (msgid, username, entrystamp, summary, node, details) FROM stdin;
1	admin	1590672981163	Successful admin console login attempt	xmpp1.localhost.example	The user logged in successfully to the admin console from address 172.50.0.1. 
2	admin	1590673013431	created new user user1	xmpp1.localhost.example	name = User One, email = null, admin = false
3	admin	1590673034080	created new user user2	xmpp1.localhost.example	name = User Two, email = null, admin = false
4	admin	1590673128038	created new MUC room muc1	xmpp1.localhost.example	subject = \nroomdesc = First MUC room\nroomname = MUC One\nmaxusers = 30
5	admin	1590673151904	created new MUC room muc2	xmpp1.localhost.example	subject = \nroomdesc = Second MUC room\nroomname = MUC Two\nmaxusers = 30
\.


--
-- Data for Name: ofuser; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofuser (username, storedkey, serverkey, salt, iterations, plainpassword, encryptedpassword, name, email, creationdate, modificationdate) FROM stdin;
admin	4pTIOhLJhGFoQCTNLUWVMhVWKIA=	7tARkdREK7ZcRzbsfoDBPbhLL9E=	PccUHLcQH5lmcHYbmRSrYBqMjJgRPwyl	4096	\N	\N	Administrator	admin@example.com	0              	0              
user1	3ar4LqqIzI0KGpiRrqgyb5/YUsw=	BjAVK1JXsL7k4XNdwnbNt9vFRg8=	W4HLLSaH6N1j61lFnONzDgp0da9wEQBB	4096	\N	\N	User One	\N	001590673013409	001590673013409
user2	jq2EWErRHZ9T9QV0JysJlK4JMMM=	FdKTuSUJQgnmkm3rTb4KbcoQwko=	KfGGJgak3MBZMwelH/UVnyqbrfrWnFD8	4096	\N	\N	User Two	\N	001590673034068	001590673034068
\.


--
-- Data for Name: ofuserflag; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofuserflag (username, name, starttime, endtime) FROM stdin;
\.


--
-- Data for Name: ofuserprop; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofuserprop (username, name, propvalue) FROM stdin;
\.


--
-- Data for Name: ofvcard; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofvcard (username, vcard) FROM stdin;
\.


--
-- Data for Name: ofversion; Type: TABLE DATA; Schema: public; Owner: openfire
--

COPY public.ofversion (name, version) FROM stdin;
openfire	32
\.


--
-- Name: ofextcomponentconf ofextcomponentconf_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofextcomponentconf
    ADD CONSTRAINT ofextcomponentconf_pk PRIMARY KEY (subdomain);


--
-- Name: ofgroup ofgroup_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofgroup
    ADD CONSTRAINT ofgroup_pk PRIMARY KEY (groupname);


--
-- Name: ofgroupprop ofgroupprop_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofgroupprop
    ADD CONSTRAINT ofgroupprop_pk PRIMARY KEY (groupname, name);


--
-- Name: ofgroupuser ofgroupuser_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofgroupuser
    ADD CONSTRAINT ofgroupuser_pk PRIMARY KEY (groupname, username, administrator);


--
-- Name: ofid ofid_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofid
    ADD CONSTRAINT ofid_pk PRIMARY KEY (idtype);


--
-- Name: ofmucaffiliation ofmucaffiliation_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofmucaffiliation
    ADD CONSTRAINT ofmucaffiliation_pk PRIMARY KEY (roomid, jid);


--
-- Name: ofmucmember ofmucmember_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofmucmember
    ADD CONSTRAINT ofmucmember_pk PRIMARY KEY (roomid, jid);


--
-- Name: ofmucroom ofmucroom_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofmucroom
    ADD CONSTRAINT ofmucroom_pk PRIMARY KEY (serviceid, name);


--
-- Name: ofmucroomprop ofmucroomprop_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofmucroomprop
    ADD CONSTRAINT ofmucroomprop_pk PRIMARY KEY (roomid, name);


--
-- Name: ofmucservice ofmucservice_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofmucservice
    ADD CONSTRAINT ofmucservice_pk PRIMARY KEY (subdomain);


--
-- Name: ofmucserviceprop ofmucserviceprop_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofmucserviceprop
    ADD CONSTRAINT ofmucserviceprop_pk PRIMARY KEY (serviceid, name);


--
-- Name: ofoffline ofoffline_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofoffline
    ADD CONSTRAINT ofoffline_pk PRIMARY KEY (username, messageid);


--
-- Name: ofpresence ofpresence_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofpresence
    ADD CONSTRAINT ofpresence_pk PRIMARY KEY (username);


--
-- Name: ofprivacylist ofprivacylist_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofprivacylist
    ADD CONSTRAINT ofprivacylist_pk PRIMARY KEY (username, name);


--
-- Name: ofproperty ofproperty_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofproperty
    ADD CONSTRAINT ofproperty_pk PRIMARY KEY (name);


--
-- Name: ofpubsubaffiliation ofpubsubaffiliation_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofpubsubaffiliation
    ADD CONSTRAINT ofpubsubaffiliation_pk PRIMARY KEY (serviceid, nodeid, jid);


--
-- Name: ofpubsubdefaultconf ofpubsubdefaultconf_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofpubsubdefaultconf
    ADD CONSTRAINT ofpubsubdefaultconf_pk PRIMARY KEY (serviceid, leaf);


--
-- Name: ofpubsubitem ofpubsubitem_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofpubsubitem
    ADD CONSTRAINT ofpubsubitem_pk PRIMARY KEY (serviceid, nodeid, id);


--
-- Name: ofpubsubnode ofpubsubnode_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofpubsubnode
    ADD CONSTRAINT ofpubsubnode_pk PRIMARY KEY (serviceid, nodeid);


--
-- Name: ofpubsubnodejids ofpubsubnodejids_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofpubsubnodejids
    ADD CONSTRAINT ofpubsubnodejids_pk PRIMARY KEY (serviceid, nodeid, jid);


--
-- Name: ofpubsubsubscription ofpubsubsubscription_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofpubsubsubscription
    ADD CONSTRAINT ofpubsubsubscription_pk PRIMARY KEY (serviceid, nodeid, id);


--
-- Name: ofremoteserverconf ofremoteserverconf_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofremoteserverconf
    ADD CONSTRAINT ofremoteserverconf_pk PRIMARY KEY (xmppdomain);


--
-- Name: ofroster ofroster_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofroster
    ADD CONSTRAINT ofroster_pk PRIMARY KEY (rosterid);


--
-- Name: ofrostergroups ofrostergroups_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofrostergroups
    ADD CONSTRAINT ofrostergroups_pk PRIMARY KEY (rosterid, rank);


--
-- Name: ofsaslauthorized ofsaslauthorized_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofsaslauthorized
    ADD CONSTRAINT ofsaslauthorized_pk PRIMARY KEY (username, principal);


--
-- Name: ofsecurityauditlog ofsecurityauditlog_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofsecurityauditlog
    ADD CONSTRAINT ofsecurityauditlog_pk PRIMARY KEY (msgid);


--
-- Name: ofuser ofuser_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofuser
    ADD CONSTRAINT ofuser_pk PRIMARY KEY (username);


--
-- Name: ofuserflag ofuserflag_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofuserflag
    ADD CONSTRAINT ofuserflag_pk PRIMARY KEY (username, name);


--
-- Name: ofuserprop ofuserprop_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofuserprop
    ADD CONSTRAINT ofuserprop_pk PRIMARY KEY (username, name);


--
-- Name: ofvcard ofvcard_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofvcard
    ADD CONSTRAINT ofvcard_pk PRIMARY KEY (username);


--
-- Name: ofversion ofversion_pk; Type: CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofversion
    ADD CONSTRAINT ofversion_pk PRIMARY KEY (name);


--
-- Name: ofmucconversationlog_msg_id; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofmucconversationlog_msg_id ON public.ofmucconversationlog USING btree (messageid);


--
-- Name: ofmucconversationlog_time_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofmucconversationlog_time_idx ON public.ofmucconversationlog USING btree (logtime);


--
-- Name: ofmucroom_roomid_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofmucroom_roomid_idx ON public.ofmucroom USING btree (roomid);


--
-- Name: ofmucroom_serviceid_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofmucroom_serviceid_idx ON public.ofmucroom USING btree (serviceid);


--
-- Name: ofmucservice_serviceid_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofmucservice_serviceid_idx ON public.ofmucservice USING btree (serviceid);


--
-- Name: ofprivacylist_default_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofprivacylist_default_idx ON public.ofprivacylist USING btree (username, isdefault);


--
-- Name: ofpubsubnodegroups_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofpubsubnodegroups_idx ON public.ofpubsubnodegroups USING btree (serviceid, nodeid);


--
-- Name: ofroster_jid_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofroster_jid_idx ON public.ofroster USING btree (jid);


--
-- Name: ofroster_username_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofroster_username_idx ON public.ofroster USING btree (username);


--
-- Name: ofrostergroups_rosterid_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofrostergroups_rosterid_idx ON public.ofrostergroups USING btree (rosterid);


--
-- Name: ofsecurityauditlog_tstamp_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofsecurityauditlog_tstamp_idx ON public.ofsecurityauditlog USING btree (entrystamp);


--
-- Name: ofsecurityauditlog_uname_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofsecurityauditlog_uname_idx ON public.ofsecurityauditlog USING btree (username);


--
-- Name: ofuser_cdate_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofuser_cdate_idx ON public.ofuser USING btree (creationdate);


--
-- Name: ofuserflag_etime_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofuserflag_etime_idx ON public.ofuserflag USING btree (endtime);


--
-- Name: ofuserflag_stime_idx; Type: INDEX; Schema: public; Owner: openfire
--

CREATE INDEX ofuserflag_stime_idx ON public.ofuserflag USING btree (starttime);


--
-- Name: ofrostergroups ofrostergroups_rosterid_fk; Type: FK CONSTRAINT; Schema: public; Owner: openfire
--

ALTER TABLE ONLY public.ofrostergroups
    ADD CONSTRAINT ofrostergroups_rosterid_fk FOREIGN KEY (rosterid) REFERENCES public.ofroster(rosterid) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

