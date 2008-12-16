From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Dec 2008 12:30:40 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20081216123040.1585.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-16 12:30:40

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	Rename 'cmd' to 'clvmd_cmd' to remove ambiguity.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: James Cameron <james.cameron@hp.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/locking/cluster_locking.c	2008/11/04 15:07:44	1.31
+++ LVM2/lib/locking/cluster_locking.c	2008/12/16 12:30:39	1.32
@@ -164,10 +164,11 @@
 }
 
 /* Build the structure header and parse-out wildcard node names */
-static void _build_header(struct clvm_header *head, int cmd, const char *node,
+/* FIXME: Cleanup implicit casts of clvmd_cmd (int, char, uint8_t, etc). */
+static void _build_header(struct clvm_header *head, int clvmd_cmd, const char *node,
 			  int len)
 {
-	head->cmd = cmd;
+	head->cmd = clvmd_cmd;
 	head->status = 0;
 	head->flags = 0;
 	head->clientid = 0;
@@ -193,7 +194,7 @@
 /*
  * Send a message to a(or all) node(s) in the cluster and wait for replies
  */
-static int _cluster_request(char cmd, const char *node, void *data, int len,
+static int _cluster_request(char clvmd_cmd, const char *node, void *data, int len,
 			   lvm_response_t ** response, int *num)
 {
 	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1] __attribute((aligned(8)));
@@ -213,7 +214,7 @@
 	if (_clvmd_sock == -1)
 		return 0;
 
-	_build_header(head, cmd, node, len);
+	_build_header(head, clvmd_cmd, node, len);
 	memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
@@ -296,7 +297,7 @@
 	return 1;
 }
 
-static int _lock_for_cluster(unsigned char cmd, uint32_t flags, const char *name)
+static int _lock_for_cluster(unsigned char clvmd_cmd, uint32_t flags, const char *name)
 {
 	int status;
 	int i;
@@ -332,13 +333,13 @@
 	 * the cluster because they might have side-effects.
 	 */
 	if (strncmp(name, "P_", 2) &&
-	    (cmd == CLVMD_CMD_LOCK_VG ||
+	    (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
 	     (flags & LCK_TYPE_MASK) == LCK_EXCL ||
 	     (flags & LCK_LOCAL) ||
 	     !(flags & LCK_CLUSTER_VG)))
 		node = ".";
 
-	status = _cluster_request(cmd, node, args, len,
+	status = _cluster_request(clvmd_cmd, node, args, len,
 				  &response, &num_responses);
 
 	/* If any nodes were down then display them and return an error */
@@ -375,7 +376,7 @@
 #endif
 {
 	char lockname[PATH_MAX];
-	int cluster_cmd = 0;
+	int clvmd_cmd = 0;
 	const char *lock_scope;
 	const char *lock_type = "";
 
@@ -393,12 +394,12 @@
 				    resource);
 
 		lock_scope = "VG";
-		cluster_cmd = CLVMD_CMD_LOCK_VG;
+		clvmd_cmd = CLVMD_CMD_LOCK_VG;
 		flags &= LCK_TYPE_MASK;
 		break;
 
 	case LCK_LV:
-		cluster_cmd = CLVMD_CMD_LOCK_LV;
+		clvmd_cmd = CLVMD_CMD_LOCK_LV;
 		strcpy(lockname, resource);
 		lock_scope = "LV";
 		flags &= 0xffdf;	/* Mask off HOLD flag */
@@ -436,7 +437,7 @@
 	}
 
 	/* If we are unlocking a clustered VG, then trigger remote metadata backups */
-	if (cluster_cmd == CLVMD_CMD_LOCK_VG &&
+	if (clvmd_cmd == CLVMD_CMD_LOCK_VG &&
 	    ((flags & LCK_TYPE_MASK) == LCK_UNLOCK) &&
 	    (flags & LCK_CLUSTER_VG)) {
 		log_very_verbose("Requesing backup of VG metadata for %s", resource);
@@ -452,7 +453,7 @@
 			 flags);
 
 	/* Send a message to the cluster manager */
-	return _lock_for_cluster(cluster_cmd, flags, lockname);
+	return _lock_for_cluster(clvmd_cmd, flags, lockname);
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL


