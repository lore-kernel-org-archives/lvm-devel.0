From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 14 Jun 2007 10:16:35 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/Makefile.in dae ...
Message-ID: <20070614101635.28262.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2007-06-14 10:16:35

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : Makefile.in clvmd.c 

Log message:
	Remove system LV code from clvmd. It's never been used and never should be
	used! It's removal tidies a number of code paths inside clvmd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.631&r2=1.632
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2007/06/13 23:57:15	1.631
+++ LVM2/WHATS_NEW	2007/06/14 10:16:34	1.632
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Remove system-lv code from clvmd. It's highly dodgy and never used.
   Convert a lot of code pv dereferences to use get_pv_* functions.
   Suppress a couple benign warnings by adding variable initializations.
   Convert find_pv_in_vg_by_uuid and pv_create to use PV handles.
--- LVM2/daemons/clvmd/Makefile.in	2007/05/21 10:52:01	1.18
+++ LVM2/daemons/clvmd/Makefile.in	2007/06/14 10:16:34	1.19
@@ -19,8 +19,7 @@
 	clvmd-command.c  \
 	clvmd.c          \
 	lvm-functions.c  \
-	refresh_clvmd.c \
-	system-lv.c
+	refresh_clvmd.c
 
 ifeq ("@CLVMD@", "gulm")
 	GULM = yes
--- LVM2/daemons/clvmd/clvmd.c	2007/05/21 10:52:01	1.37
+++ LVM2/daemons/clvmd/clvmd.c	2007/06/14 10:16:35	1.38
@@ -45,7 +45,6 @@
 #include "version.h"
 #include "clvmd.h"
 #include "refresh_clvmd.h"
-#include "system-lv.h"
 #include "list.h"
 #include "log.h"
 
@@ -58,10 +57,6 @@
 
 #define MAX_RETRIES 4
 
-/* The maximum size of a message that will fit into a packet. Anything bigger
-   than this is sent via the system LV */
-#define MAX_INLINE_MESSAGE (max_cluster_message-sizeof(struct clvm_header))
-
 #define ISLOCAL_CSID(c) (memcmp(c, our_csid, max_csid_len) == 0)
 
 /* Head of the fd list. Also contains
@@ -1062,31 +1057,6 @@
 	return 0;
 }
 
-
-/*
- * Send a long message using the System LV
- */
-static int send_long_message(struct local_client *thisfd, struct clvm_header *inheader, int len)
-{
-    struct clvm_header new_header;
-    int status;
-
-    DEBUGLOG("Long message: being sent via system LV:\n");
-
-    /* Use System LV */
-    status = system_lv_write_data((char *)inheader, len);
-    if (status < 0)
-	    return errno;
-
-    /* Send message indicating System-LV is being used */
-    memcpy(&new_header, inheader, sizeof(new_header));
-    new_header.flags |= CLVMD_FLAG_SYSTEMLV;
-    new_header.xid = thisfd->xid;
-
-    return send_message(&new_header, sizeof(new_header), NULL, -1,
-		 "Error forwarding long message to cluster");
-}
-
 /* Called when the pre-command has completed successfully - we
    now execute the real command on all the requested nodes */
 static int distribute_command(struct local_client *thisfd)
@@ -1113,13 +1083,9 @@
 			add_to_lvmqueue(thisfd, inheader, len, NULL);
 
 			DEBUGLOG("Sending message to all cluster nodes\n");
-			if (len > MAX_INLINE_MESSAGE) {
-			        send_long_message(thisfd, inheader, len );
-			} else {
-				inheader->xid = thisfd->xid;
-				send_message(inheader, len, NULL, -1,
-					     "Error forwarding message to cluster");
-			}
+			inheader->xid = thisfd->xid;
+			send_message(inheader, len, NULL, -1,
+				     "Error forwarding message to cluster");
 		} else {
                         /* Do it on a single node */
 			char csid[MAX_CSID_LEN];
@@ -1140,14 +1106,10 @@
 				} else {
 					DEBUGLOG("Sending message to single node: %s\n",
 						 inheader->node);
-					if (len > MAX_INLINE_MESSAGE) {
-					        send_long_message(thisfd, inheader, len );
-					} else {
-						inheader->xid = thisfd->xid;
-						send_message(inheader, len,
-							     csid, -1,
-							     "Error forwarding message to cluster node");
-					}
+					inheader->xid = thisfd->xid;
+					send_message(inheader, len,
+						     csid, -1,
+						     "Error forwarding message to cluster node");
 				}
 			}
 		}
@@ -1178,55 +1140,6 @@
 	DEBUGLOG("process_remote_command %d for clientid 0x%x XID %d on node %s\n",
 		 msg->cmd, msg->clientid, msg->xid, nodename);
 
-	/* Is the data to be found in the system LV ? */
-	if (msg->flags & CLVMD_FLAG_SYSTEMLV) {
-		struct clvm_header *newmsg;
-
-		DEBUGLOG("Reading message from system LV\n");
-		newmsg =
-		    (struct clvm_header *) malloc(msg->arglen +
-						  sizeof(struct clvm_header));
-		if (newmsg) {
-			ssize_t len;
-			if (system_lv_read_data(nodename, (char *) newmsg,
-			     			&len) == 0) {
-				msg = newmsg;
-				msg_malloced = 1;
-				msglen = len;
-			} else {
-				struct clvm_header head;
-				DEBUGLOG("System LV read failed\n");
-
-				/* Return a failure response */
-				head.cmd = CLVMD_CMD_REPLY;
-				head.status = EFBIG;
-				head.flags = 0;
-				head.clientid = msg->clientid;
-				head.arglen = 0;
-				head.node[0] = '\0';
-				send_message(&head, sizeof(struct clvm_header),
-					     csid, fd,
-					     "Error sending ENOMEM command reply");
-				return;
-			}
-		} else {
-			struct clvm_header head;
-			DEBUGLOG
-			    ("Error attempting to malloc %d bytes for system LV read\n",
-			     msg->arglen);
-			/* Return a failure response */
-			head.cmd = CLVMD_CMD_REPLY;
-			head.status = ENOMEM;
-			head.flags = 0;
-			head.clientid = msg->clientid;
-			head.arglen = 0;
-			head.node[0] = '\0';
-			send_message(&head, sizeof(struct clvm_header), csid,
-				     fd, "Error sending ENOMEM command reply");
-			return;
-		}
-	}
-
 	/* Check for GOAWAY and sulk */
 	if (msg->cmd == CLVMD_CMD_GOAWAY) {
 
@@ -1301,40 +1214,16 @@
 				replyargs, replylen);
 
 			agghead->xid = msg->xid;
-
-			/* Use the system LV ? */
-			if (replylen > MAX_INLINE_MESSAGE) {
-				agghead->cmd = CLVMD_CMD_REPLY;
-				agghead->status = status;
-				agghead->flags = CLVMD_FLAG_SYSTEMLV;
-				agghead->clientid = msg->clientid;
-				agghead->arglen = replylen;
-				agghead->node[0] = '\0';
-
-				/* If System LV operation failed then report it as EFBIG but only do it
-				   if the data buffer has something in it. */
-				if (system_lv_write_data(aggreply,
-							 replylen + sizeof(struct clvm_header)) < 0
-				    && replylen > 0)
-					agghead->status = EFBIG;
-
-				send_message(agghead,
-					     sizeof(struct clvm_header), csid,
-					     fd,
-					     "Error sending long command reply");
-
-			} else {
-				agghead->cmd = CLVMD_CMD_REPLY;
-				agghead->status = status;
-				agghead->flags = 0;
-				agghead->clientid = msg->clientid;
-				agghead->arglen = replylen;
-				agghead->node[0] = '\0';
-				send_message(aggreply,
-					     sizeof(struct clvm_header) +
-					     replylen, csid, fd,
-					     "Error sending command reply");
-			}
+			agghead->cmd = CLVMD_CMD_REPLY;
+			agghead->status = status;
+			agghead->flags = 0;
+			agghead->clientid = msg->clientid;
+			agghead->arglen = replylen;
+			agghead->node[0] = '\0';
+			send_message(aggreply,
+				     sizeof(struct clvm_header) +
+				     replylen, csid, fd,
+				     "Error sending command reply");
 		} else {
 			struct clvm_header head;
 


