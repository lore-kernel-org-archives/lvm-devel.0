From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Jan 2012 05:29:53 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/l ...
Message-ID: <20120121052953.28441.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-21 05:29:52

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 
	lib/locking    : cluster_locking.c locking.c locking.h 

Log message:
	Attempt to improve clustered 'lvchange -aey' behaviour to try local node before
	remote nodes and address some existing anomalies.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2233&r2=1.2234
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.232&r2=1.233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW	2012/01/20 22:04:16	1.2233
+++ LVM2/WHATS_NEW	2012/01/21 05:29:51	1.2234
@@ -1,5 +1,7 @@
 Version 2.02.89 - 
 ==================================
+  Change exclusive LV activation logic to try local node before remote nodes.
+  Add CLVMD_FLAG_REMOTE to skip processing on local node.
   Prompt if request is made to remove a snapshot whose "Merge failed".
   Allow removal of an invalid snapshot that was to be merged on next activation.
   Don't allow a user to merge an invalid snapshot.
--- LVM2/lib/activate/activate.c	2012/01/20 03:46:52	1.232
+++ LVM2/lib/activate/activate.c	2012/01/21 05:29:52	1.233
@@ -930,7 +930,8 @@
 		l = 1;
 
 	if (!vg_is_clustered(lv->vg)) {
-		e = 1;  /* exclusive by definition */
+		if (l)
+			e = 1;  /* exclusive by definition */
 		goto out;
 	}
 
@@ -950,21 +951,15 @@
 	 * New users of this function who specifically ask for 'exclusive'
 	 * will be given an error message.
 	 */
-	if (l) {
-		if (exclusive)
-			log_error("Unable to determine exclusivity of %s",
-				  lv->name);
-		goto out;
-	}
+	log_error("Unable to determine exclusivity of %s", lv->name);
+
+	e = 0;
+
+	/*
+	 * We used to attempt activate_lv_excl_local(lv->vg->cmd, lv) here,
+	 * but it's unreliable.
+	 */
 
-	/* FIXME: Is this fallback alright? */
-	if (activate_lv_excl(lv->vg->cmd, lv)) {
-		if (!deactivate_lv(lv->vg->cmd, lv))
-			stack;
-		/* FIXME: locally & exclusive are undefined. */
-		return 0;
-	}
-	/* FIXME: Check exclusive value here. */
 out:
 	if (locally)
 		*locally = l;
--- LVM2/lib/locking/cluster_locking.c	2011/12/08 18:19:05	1.63
+++ LVM2/lib/locking/cluster_locking.c	2012/01/21 05:29:52	1.64
@@ -178,21 +178,19 @@
 	head->clientid = 0;
 	head->arglen = len;
 
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
+	 * Handle special node names.
+	 */
+	if (!node || !strcmp(node, NODE_ALL))
+		head->node[0] = '\0';
+	else if (!strcmp(node, NODE_LOCAL)) {
 		head->node[0] = '\0';
+		head->flags = CLVMD_FLAG_LOCAL;
+	} else if (!strcmp(node, NODE_REMOTE)) {
+		head->node[0] = '\0';
+		head->flags = CLVMD_FLAG_REMOTE;
+	} else
+		strcpy(head->node, node);
 }
 
 /*
@@ -357,9 +355,6 @@
 	 * so we only need to do them on the local node because all
 	 * locks are cluster-wide.
 	 *
-	 * Also, if the lock is exclusive it makes no sense to try to
-	 * acquire it on all nodes, so just do that on the local node too.
-	 *
 	 * P_ locks /do/ get distributed across the cluster because they might
 	 * have side-effects.
 	 *
@@ -367,13 +362,15 @@
 	 */
 	if (clvmd_cmd == CLVMD_CMD_SYNC_NAMES) {
 		if (flags & LCK_LOCAL)
-			node = ".";
+			node = NODE_LOCAL;
 	} else if (clvmd_cmd != CLVMD_CMD_VG_BACKUP) {
 		if (strncmp(name, "P_", 2) &&
 		    (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
 		     (flags & LCK_LOCAL) ||
 		     !(flags & LCK_CLUSTER_VG)))
-			node = ".";
+			node = NODE_LOCAL;
+		else if (flags & LCK_REMOTE)
+			node = NODE_REMOTE;
 	}
 
 	status = _cluster_request(clvmd_cmd, node, args, len,
@@ -493,12 +490,13 @@
 		return 0;
 	}
 
-	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
+	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
 			 lock_type, lock_scope,
 			 flags & LCK_NONBLOCK ? "|NONBLOCK" : "",
 			 flags & LCK_HOLD ? "|HOLD" : "",
-			 flags & LCK_LOCAL ? "|LOCAL" : "",
 			 flags & LCK_CLUSTER_VG ? "|CLUSTER" : "",
+			 flags & LCK_LOCAL ? "|LOCAL" : "",
+			 flags & LCK_REMOTE ? "|REMOTE" : "",
 			 flags & LCK_CACHE ? "|CACHE" : "",
 			 flags & LCK_ORIGIN_ONLY ? "|ORIGIN_ONLY" : "",
 			 flags & LCK_REVERT ? "|REVERT" : "",
--- LVM2/lib/locking/locking.c	2012/01/10 02:03:32	1.101
+++ LVM2/lib/locking/locking.c	2012/01/21 05:29:52	1.102
@@ -539,6 +539,33 @@
 	return 1;
 }
 
+/*
+ * First try to activate exclusively locally.
+ * Then if the VG is clustered and the LV is not yet active (e.g. due to 
+ * an activation filter) try activating on remote nodes.
+ */
+int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv) 
+{
+	/* Non-clustered VGs are only activated locally. */
+	if (!vg_is_clustered(lv->vg))
+		return activate_lv_excl_local(cmd, lv);
+
+	if (lv_is_active_exclusive(lv))
+		return 1;
+
+	if (!activate_lv_excl_local(cmd, lv))
+		return_0;
+
+	if (lv_is_active_exclusive(lv))
+		return 1;
+
+	/* FIXME Deal with error return codes. */
+	if (activate_lv_excl_remote(cmd, lv))
+		stack;
+
+	return lv_is_active_exclusive(lv);
+}
+
 /* Lock a list of LVs */
 int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive)
 {
--- LVM2/lib/locking/locking.h	2011/12/08 18:09:48	1.73
+++ LVM2/lib/locking/locking.h	2012/01/21 05:29:52	1.74
@@ -97,6 +97,7 @@
 #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
+#define LCK_REMOTE	0x00000800U	/* Propagate to remote nodes only */
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 #define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
 #define LCK_REVERT	0x00000400U	/* Revert any incomplete change */
@@ -176,9 +177,16 @@
 #define suspend_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD)
 #define suspend_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD | LCK_ORIGIN_ONLY)
 #define deactivate_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE)
+
 #define activate_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD)
-#define activate_lv_excl(cmd, lv)	\
-				lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD)
+#define activate_lv_excl_local(cmd, lv)	\
+				lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_LOCAL)
+#define activate_lv_excl_remote(cmd, lv)	\
+				lock_lv_vol(cmd, lv, LCK_LV_EXCLUSIVE | LCK_HOLD | LCK_REMOTE)
+
+struct logical_volume;
+int activate_lv_excl(struct cmd_context *cmd, struct logical_volume *lv);
+
 #define activate_lv_local(cmd, lv)	\
 	lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD | LCK_LOCAL)
 #define deactivate_lv_local(cmd, lv)	\


