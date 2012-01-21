From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Jan 2012 05:31:55 -0000
Subject: LVM2/daemons/clvmd clvm.h clvmd.c refresh_clvmd.c
Message-ID: <20120121053155.29182.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-21 05:31:54

Modified files:
	daemons/clvmd  : clvm.h clvmd.c refresh_clvmd.c 

Log message:
	Add CLVMD_FLAG_REMOTE to skip processing on local node.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvm.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/daemons/clvmd/clvm.h	2011/01/12 20:42:50	1.10
+++ LVM2/daemons/clvmd/clvm.h	2012/01/21 05:31:54	1.11
@@ -36,16 +36,17 @@
 	char node[1];		/* Actually a NUL-terminated string, node name.
 				   If this is empty then the command is 
 				   forwarded to all cluster nodes unless 
-				   FLAG_LOCAL is also set. */
+				   FLAG_LOCAL or FLAG_REMOTE is also set. */
 	char args[1];		/* Arguments for the command follow the 
 				   node name, This member is only
 				   valid if the node name is empty */
 } __attribute__ ((packed));
 
 /* Flags */
-#define CLVMD_FLAG_LOCAL        1	/* Only do this on the local node */
-#define CLVMD_FLAG_SYSTEMLV     2	/* Data in system LV under my node name */
-#define CLVMD_FLAG_NODEERRS     4       /* Reply has errors in node-specific portion */
+#define CLVMD_FLAG_LOCAL	1	/* Only do this on the local node */
+#define CLVMD_FLAG_SYSTEMLV	2	/* Data in system LV under my node name */
+#define CLVMD_FLAG_NODEERRS	4	/* Reply has errors in node-specific portion */
+#define CLVMD_FLAG_REMOTE	8	/* Do this on all nodes except for the local node */
 
 /* Name of the local socket to communicate between lvm and clvmd */
 static const char CLVMD_SOCKNAME[]= DEFAULT_RUN_DIR "/clvmd.sock";
@@ -72,4 +73,10 @@
 #define CLVMD_CMD_VG_BACKUP	    43
 #define CLVMD_CMD_RESTART	    44
 #define CLVMD_CMD_SYNC_NAMES	    45
+
+/* Used internally by some callers, but not part of the protocol.*/
+#define NODE_ALL	"*"
+#define NODE_LOCAL	"."
+#define NODE_REMOTE	"^"
+
 #endif
--- LVM2/daemons/clvmd/clvmd.c	2011/10/11 10:06:57	1.116
+++ LVM2/daemons/clvmd/clvmd.c	2012/01/21 05:31:54	1.117
@@ -1396,7 +1396,10 @@
 	int len = thisfd->bits.localsock.cmd_len;
 
 	thisfd->xid = global_xid++;
-	DEBUGLOG("distribute command: XID = %d\n", thisfd->xid);
+	DEBUGLOG("distribute command: XID = %d, flags=0x%x (%s%s)\n",
+		 thisfd->xid, inheader->flags,
+		(inheader->flags & CLVMD_FLAG_LOCAL) ? "LOCAL" : "",
+		(inheader->flags & CLVMD_FLAG_REMOTE) ? "REMOTE" : "");
 
 	/* Forward it to other nodes in the cluster if needed */
 	if (!(inheader->flags & CLVMD_FLAG_LOCAL)) {
@@ -1409,7 +1412,11 @@
 			thisfd->bits.localsock.in_progress = TRUE;
 			thisfd->bits.localsock.sent_out = TRUE;
 
-			/* Do it here first */
+			/*
+			 * Send to local node first, even if CLVMD_FLAG_REMOTE
+			 * is set so we still get a reply if this is the
+			 * only node.
+			 */
 			add_to_lvmqueue(thisfd, inheader, len, NULL);
 
 			DEBUGLOG("Sending message to all cluster nodes\n");
@@ -1735,8 +1742,12 @@
 	if (replybuf == NULL)
 		return -1;
 
-	/* FIXME: usage of init_test() is unprotected */
-	status = do_command(client, msg, msglen, &replybuf, buflen, &replylen);
+	/* If remote flag is set, just set a successful status code. */
+	if (msg->flags & CLVMD_FLAG_REMOTE)
+		status = 0;
+	else
+		/* FIXME: usage of init_test() is unprotected */
+		status = do_command(client, msg, msglen, &replybuf, buflen, &replylen);
 
 	if (status)
 		client->bits.localsock.all_success = 0;
--- LVM2/daemons/clvmd/refresh_clvmd.c	2011/09/21 13:40:46	1.16
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2012/01/21 05:31:54	1.17
@@ -13,6 +13,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+/* FIXME Remove duplicated functions from this file. */
+
 /*
  * Send a command to a running clvmd from the command-line
  */
@@ -164,21 +166,16 @@
 		*head->args = '\0';
 	}
 
-	if (node) {
-		/*
-		 * Allow a couple of special node names:
-		 * "*" for all nodes,
-		 * "." for the local node only
-		 */
-		if (strcmp(node, "*") == 0) {
-			head->node[0] = '\0';
-		} else if (strcmp(node, ".") == 0) {
-			head->node[0] = '\0';
-			head->flags = CLVMD_FLAG_LOCAL;
-		} else
-			strcpy(head->node, node);
-	} else
+	/*
+	 * Translate special node names.
+	 */
+	if (!node || !strcmp(node, NODE_ALL))
+		head->node[0] = '\0';
+	else if (!strcmp(node, NODE_LOCAL)) {
 		head->node[0] = '\0';
+		head->flags = CLVMD_FLAG_LOCAL;
+	} else
+		strcpy(head->node, node);
 }
 
 /*
@@ -298,7 +295,7 @@
 	int status;
 	int i;
 
-	status = _cluster_request(CLVMD_CMD_REFRESH, all_nodes?"*":".", args, 0, &response, &num_responses, 0);
+	status = _cluster_request(CLVMD_CMD_REFRESH, all_nodes ? NODE_ALL : NODE_LOCAL, args, 0, &response, &num_responses, 0);
 
 	/* If any nodes were down then display them and return an error */
 	for (i = 0; i < num_responses; i++) {
@@ -329,7 +326,7 @@
 {
 	int dummy, status;
 
-	status = _cluster_request(CLVMD_CMD_RESTART, all_nodes?"*":".", NULL, 0, NULL, &dummy, 1);
+	status = _cluster_request(CLVMD_CMD_RESTART, all_nodes ? NODE_ALL : NODE_LOCAL, NULL, 0, NULL, &dummy, 1);
 
 	/*
 	 * FIXME: we cannot receive response, clvmd re-exec before it.
@@ -356,9 +353,9 @@
 
 	args[0] = level;
 	if (clusterwide)
-		nodes = "*";
+		nodes = NODE_ALL;
 	else
-		nodes = ".";
+		nodes = NODE_LOCAL;
 
 	status = _cluster_request(CLVMD_CMD_SET_DEBUG, nodes, args, 1, &response, &num_responses, 0);
 


