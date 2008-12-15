From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 15 Dec 2008 16:44:42 -0500
Subject: [PATCH] Rename 'cmd' to 'clvmd_cmd' to remove ambiguity.
Message-ID: <1229377482-24313-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/locking/cluster_locking.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index f230dda..337d452 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -164,10 +164,10 @@ static int _send_request(char *inbuf, int inlen, char **retbuf)
 }
 
 /* Build the structure header and parse-out wildcard node names */
-static void _build_header(struct clvm_header *head, int cmd, const char *node,
+static void _build_header(struct clvm_header *head, int clvmd_cmd, const char *node,
 			  int len)
 {
-	head->cmd = cmd;
+	head->cmd = clvmd_cmd;
 	head->status = 0;
 	head->flags = 0;
 	head->clientid = 0;
@@ -193,7 +193,7 @@ static void _build_header(struct clvm_header *head, int cmd, const char *node,
 /*
  * Send a message to a(or all) node(s) in the cluster and wait for replies
  */
-static int _cluster_request(char cmd, const char *node, void *data, int len,
+static int _cluster_request(char clvmd_cmd, const char *node, void *data, int len,
 			   lvm_response_t ** response, int *num)
 {
 	char outbuf[sizeof(struct clvm_header) + len + strlen(node) + 1] __attribute((aligned(8)));
@@ -213,7 +213,7 @@ static int _cluster_request(char cmd, const char *node, void *data, int len,
 	if (_clvmd_sock == -1)
 		return 0;
 
-	_build_header(head, cmd, node, len);
+	_build_header(head, clvmd_cmd, node, len);
 	memcpy(head->node + strlen(head->node) + 1, data, len);
 
 	status = _send_request(outbuf, sizeof(struct clvm_header) +
@@ -296,7 +296,7 @@ static int _cluster_free_request(lvm_response_t * response, int num)
 	return 1;
 }
 
-static int _lock_for_cluster(unsigned char cmd, uint32_t flags, const char *name)
+static int _lock_for_cluster(unsigned char clvmd_cmd, uint32_t flags, const char *name)
 {
 	int status;
 	int i;
@@ -332,13 +332,13 @@ static int _lock_for_cluster(unsigned char cmd, uint32_t flags, const char *name
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
@@ -375,7 +375,7 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 #endif
 {
 	char lockname[PATH_MAX];
-	int cluster_cmd = 0;
+	int clvmd_cmd = 0;
 	const char *lock_scope;
 	const char *lock_type = "";
 
@@ -393,12 +393,12 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
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
@@ -436,7 +436,7 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 	}
 
 	/* If we are unlocking a clustered VG, then trigger remote metadata backups */
-	if (cluster_cmd == CLVMD_CMD_LOCK_VG &&
+	if (clvmd_cmd == CLVMD_CMD_LOCK_VG &&
 	    ((flags & LCK_TYPE_MASK) == LCK_UNLOCK) &&
 	    (flags & LCK_CLUSTER_VG)) {
 		log_very_verbose("Requesing backup of VG metadata for %s", resource);
@@ -452,7 +452,7 @@ int lock_resource(struct cmd_context *cmd, const char *resource, uint32_t flags)
 			 flags);
 
 	/* Send a message to the cluster manager */
-	return _lock_for_cluster(cluster_cmd, flags, lockname);
+	return _lock_for_cluster(clvmd_cmd, flags, lockname);
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL
-- 
1.5.5.1


