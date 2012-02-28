From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 09:53:57 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20120228095357.10415.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 09:53:55

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Do not send uninitilised bytes
	
	Use struct initalizers to fill struct members and at the same time have
	all unspecified members set to 0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2318&r2=1.2319
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2012/02/27 11:45:05	1.2318
+++ LVM2/WHATS_NEW	2012/02/28 09:53:55	1.2319
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Do not send uninitilised bytes in cluster error reply messages.
   Use unsigned type for bitmask instead of enum type for lvm properties.
   Add missing cleanup of excl_uuid hash on some exit paths of clvmd.
   Check for existance of vg_name in _format1/_pool_vg_read().
--- LVM2/daemons/clvmd/clvmd.c	2012/02/27 11:28:47	1.124
+++ LVM2/daemons/clvmd/clvmd.c	2012/02/28 09:53:55	1.125
@@ -1185,11 +1185,10 @@
 
 		/* If we are already busy then return an error */
 		if (thisfd->bits.localsock.in_progress) {
-			struct clvm_header reply;
-			reply.cmd = CLVMD_CMD_REPLY;
-			reply.status = EBUSY;
-			reply.arglen = 0;
-			reply.flags = 0;
+			struct clvm_header reply = {
+				.cmd = CLVMD_CMD_REPLY,
+				.status = EBUSY
+			};
 			send_message(&reply, sizeof(reply), our_csid,
 				     thisfd->fd,
 				     "Error sending EBUSY reply to local user");
@@ -1206,11 +1205,10 @@
 
 		/* We need at least sizeof(struct clvm_header) bytes in buffer */
 		if (len < sizeof(struct clvm_header) || argslen < 0) {
-			struct clvm_header reply;
-			reply.cmd = CLVMD_CMD_REPLY;
-			reply.status = EINVAL;
-			reply.arglen = 0;
-			reply.flags = 0;
+			struct clvm_header reply = {
+				.cmd = CLVMD_CMD_REPLY,
+				.status = EINVAL
+			};
 			send_message(&reply, sizeof(reply), our_csid,
 				     thisfd->fd,
 				     "Error sending EINVAL reply to local user");
@@ -1224,11 +1222,10 @@
 		thisfd->bits.localsock.cmd = malloc(len + missing_len);
 
 		if (!thisfd->bits.localsock.cmd) {
-			struct clvm_header reply;
-			reply.cmd = CLVMD_CMD_REPLY;
-			reply.status = ENOMEM;
-			reply.arglen = 0;
-			reply.flags = 0;
+			struct clvm_header reply = {
+				.cmd = CLVMD_CMD_REPLY,
+				.status = ENOMEM
+			};
 			send_message(&reply, sizeof(reply), our_csid,
 				     thisfd->fd,
 				     "Error sending ENOMEM reply to local user");
@@ -1283,13 +1280,12 @@
 		/* Check the node name for validity */
 		if (inheader->node[0] && clops->csid_from_name(csid, inheader->node)) {
 			/* Error, node is not in the cluster */
-			struct clvm_header reply;
-			DEBUGLOG("Unknown node: '%s'\n", inheader->node);
+			struct clvm_header reply = {
+				.cmd = CLVMD_CMD_REPLY,
+				.status = ENOENT
+			};
 
-			reply.cmd = CLVMD_CMD_REPLY;
-			reply.status = ENOENT;
-			reply.flags = 0;
-			reply.arglen = 0;
+			DEBUGLOG("Unknown node: '%s'\n", inheader->node);
 			send_message(&reply, sizeof(reply), our_csid,
 				     thisfd->fd,
 				     "Error sending ENOENT reply to local user");
@@ -1311,12 +1307,12 @@
 
 		/* Create a pipe and add the reading end to our FD list */
 		if (pipe(comms_pipe)) {
-			struct clvm_header reply;
+			struct clvm_header reply = {
+				.cmd = CLVMD_CMD_REPLY,
+				.status = EBUSY
+			};
+
 			DEBUGLOG("creating pipe failed: %s\n", strerror(errno));
-			reply.cmd = CLVMD_CMD_REPLY;
-			reply.status = EBUSY;
-			reply.arglen = 0;
-			reply.flags = 0;
 			send_message(&reply, sizeof(reply), our_csid,
 				     thisfd->fd,
 				     "Error sending EBUSY reply to local user");
@@ -1325,14 +1321,14 @@
 
 		newfd = malloc(sizeof(struct local_client));
 		if (!newfd) {
-			struct clvm_header reply;
+			struct clvm_header reply = {
+				.cmd = CLVMD_CMD_REPLY,
+				.status = ENOMEM
+			};
+
 			close(comms_pipe[0]);
 			close(comms_pipe[1]);
 
-			reply.cmd = CLVMD_CMD_REPLY;
-			reply.status = ENOMEM;
-			reply.arglen = 0;
-			reply.flags = 0;
 			send_message(&reply, sizeof(reply), our_csid,
 				     thisfd->fd,
 				     "Error sending ENOMEM reply to local user");


