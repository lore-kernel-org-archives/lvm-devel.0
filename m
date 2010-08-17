From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Aug 2010 19:25:08 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-singlenod ...
Message-ID: <20100817192508.27746.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-17 19:25:06

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-singlenode.c lvm-functions.c 
	lib/activate   : dev_manager.c 
	lib/locking    : cluster_locking.c file_locking.c locking.h 
	                 no_locking.c 
	lib/metadata   : mirror.c 
	tools          : lvchange.c 

Log message:
	Use 'SINGLENODE' instead of 'dead' in clvmd singlenode messages.
	Ignore snapshots when performing mirror recovery beneath an origin.
	Pass LCK_ORIGIN_ONLY flag around cluster.
	Add suspend_lv_origin and resume_lv_origin using LCK_ORIGIN_ONLY.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1708&r2=1.1709
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.200&r2=1.201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2010/08/17 16:25:32	1.1708
+++ LVM2/WHATS_NEW	2010/08/17 19:25:05	1.1709
@@ -1,5 +1,9 @@
 Version 2.02.73 - 
 ================================
+  Use 'SINGLENODE' instead of 'dead' in clvmd singlenode messages.
+  Ignore snapshots when performing mirror recovery beneath an origin.
+  Pass LCK_ORIGIN_ONLY flag around cluster.
+  Add suspend_lv_origin and resume_lv_origin using LCK_ORIGIN_ONLY.
   Allow internal suspend and resume of origin without its snapshots.
   Fix dev_manager_transient to access -real device not snapshot-origin.
   Monitor origin -real device below snapshot instead of overlay device.
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2010/08/03 13:06:35	1.6
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2010/08/17 19:25:05	1.7
@@ -108,7 +108,7 @@
 
 static int _name_from_csid(const char *csid, char *name)
 {
-	sprintf(name, "%x", 0xdead);
+	sprintf(name, "SINGLENODE");
 	return 0;
 }
 
--- LVM2/daemons/clvmd/lvm-functions.c	2010/08/17 16:25:32	1.98
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/08/17 19:25:05	1.99
@@ -122,12 +122,19 @@
 static const char *decode_flags(unsigned char flags)
 {
 	static char buf[128];
+	int len;
 
-	sprintf(buf, "0x%x (%s%s%s%s)", flags,
-		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE " : "",
-		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC " : "",
-		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "",
-		flags & LCK_CONVERT ? "CONVERT " : "");
+	len = sprintf(buf, "0x%x ( %s%s%s%s%s)", flags,
+		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE|" : "",
+		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC|" : "",
+		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR|" : "",
+		flags & LCK_ORIGIN_ONLY_MODE ? "ORIGIN_ONLY|" : "",
+		flags & LCK_CONVERT ? "CONVERT|" : "");
+
+	if (len > 1)
+		buf[len - 2] = ' ';
+	else
+		buf[0] = '\0';
 
 	return buf;
 }
@@ -350,13 +357,11 @@
 	}
 
 	/* If it's suspended then resume it */
-	// FIXME Set origin_only
 	if (!lv_info_by_lvid(cmd, resource, 0, &lvi, 0, 0))
 		goto error;
 
 	if (lvi.suspended) {
 		memlock_inc(cmd);
-		// FIXME Set origin_only
 		if (!lv_resume(cmd, resource, 0)) {
 			memlock_dec(cmd);
 			goto error;
@@ -387,8 +392,7 @@
 		return 0;	/* We don't need to do anything */
 	}
 
-	// FIXME Set origin_only
-	if (!lv_resume_if_active(cmd, resource, 0))
+	if (!lv_resume_if_active(cmd, resource, (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0))
 		return EIO;
 
 	return 0;
@@ -399,6 +403,7 @@
 {
 	int oldmode;
 	struct lvinfo lvi;
+	unsigned origin_only = (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
@@ -408,12 +413,10 @@
 	}
 
 	/* Only suspend it if it exists */
-	// FIXME Set origin_only
-	if (!lv_info_by_lvid(cmd, resource, 0, &lvi, 0, 0))
+	if (!lv_info_by_lvid(cmd, resource, origin_only, &lvi, 0, 0))
 		return EIO;
 
-	// FIXME Set origin_only
-	if (lvi.exists && !lv_suspend_if_active(cmd, resource, 0))
+	if (lvi.exists && !lv_suspend_if_active(cmd, resource, origin_only))
 		return EIO;
 
 	return 0;
@@ -558,6 +561,7 @@
 		 char *resource)
 {
 	int status;
+	unsigned origin_only = (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0;
 
 	/* Opposite of above, done on resume after a metadata update */
 	if ((command & (LCK_SCOPE_MASK | LCK_TYPE_MASK)) == LCK_LV_RESUME &&
@@ -574,8 +578,7 @@
 			struct lvinfo lvi;
 
 			pthread_mutex_lock(&lvm_lock);
-			// FIXME Set origin_only
-			status = lv_info_by_lvid(cmd, resource, 0, &lvi, 0, 0);
+			status = lv_info_by_lvid(cmd, resource, origin_only, &lvi, 0, 0);
 			pthread_mutex_unlock(&lvm_lock);
 			if (!status)
 				return EIO;
--- LVM2/lib/activate/dev_manager.c	2010/08/17 16:25:33	1.200
+++ LVM2/lib/activate/dev_manager.c	2010/08/17 19:25:05	1.201
@@ -1588,7 +1588,7 @@
 	return r;
 }
 
-static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root)
+static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, char *non_toplevel_tree_dlid)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child;
@@ -1612,6 +1612,10 @@
 		if (!*layer)
 			continue;
 
+		/* If operation was performed on a partial tree, don't remove it */
+		if (non_toplevel_tree_dlid && !strcmp(non_toplevel_tree_dlid, uuid))
+			continue;
+
 		dm_tree_set_cookie(root, 0);
 		r = dm_tree_deactivate_children(root, uuid, strlen(uuid));
 		if (!dm_udev_wait(dm_tree_get_cookie(root)))
@@ -1647,7 +1651,7 @@
 	switch(action) {
 	case CLEAN:
 		/* Deactivate any unused non-toplevel nodes */
-		if (!_clean_tree(dm, root))
+		if (!_clean_tree(dm, root, origin_only ? dlid : NULL))
 			goto_out;
 		break;
 	case DEACTIVATE:
--- LVM2/lib/locking/cluster_locking.c	2010/07/09 15:34:45	1.45
+++ LVM2/lib/locking/cluster_locking.c	2010/08/17 19:25:05	1.46
@@ -318,10 +318,13 @@
 	args = alloca(len);
 	strcpy(args + 2, name);
 
-	/* Maskoff lock flags */
+	/* Mask off lock flags */
 	args[0] = flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_NONBLOCK | LCK_HOLD); 
 	args[1] = flags & (LCK_LOCAL | LCK_CLUSTER_VG);
 
+	if (flags & LCK_ORIGIN_ONLY)
+		args[1] |= LCK_ORIGIN_ONLY_MODE;
+
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
@@ -462,13 +465,14 @@
 		return 0;
 	}
 
-	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
+	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
 			 lock_type, lock_scope,
 			 flags & LCK_NONBLOCK ? "|NONBLOCK" : "",
 			 flags & LCK_HOLD ? "|HOLD" : "",
 			 flags & LCK_LOCAL ? "|LOCAL" : "",
 			 flags & LCK_CLUSTER_VG ? "|CLUSTER" : "",
 			 flags & LCK_CACHE ? "|CACHE" : "",
+			 flags & LCK_ORIGIN_ONLY ? "|ORIGIN_ONLY" : "",
 			 flags);
 
 	/* Send a message to the cluster manager */
--- LVM2/lib/locking/file_locking.c	2010/08/17 16:25:33	1.49
+++ LVM2/lib/locking/file_locking.c	2010/08/17 19:25:05	1.50
@@ -254,6 +254,7 @@
 			       uint32_t flags)
 {
 	char lockfile[PATH_MAX];
+	unsigned origin_only = (flags & LCK_ORIGIN_ONLY) ? 1 : 0;
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
@@ -278,9 +279,8 @@
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
-			log_very_verbose("Unlocking LV %s", resource);
-			// FIXME Set origin_only
-			if (!lv_resume_if_active(cmd, resource, 0))
+			log_very_verbose("Unlocking LV %s%s", resource, origin_only ? " without snapshots" : "");
+			if (!lv_resume_if_active(cmd, resource, origin_only))
 				return 0;
 			break;
 		case LCK_NULL:
@@ -297,9 +297,8 @@
 			log_very_verbose("Locking LV %s (PR) - ignored", resource);
 			break;
 		case LCK_WRITE:
-			log_very_verbose("Locking LV %s (W)", resource);
-			// FIXME Set origin_only
-			if (!lv_suspend_if_active(cmd, resource, 0))
+			log_very_verbose("Locking LV %s (W)%s", resource, origin_only ? " without snapshots" : "");
+			if (!lv_suspend_if_active(cmd, resource, origin_only))
 				return 0;
 			break;
 		case LCK_EXCL:
--- LVM2/lib/locking/locking.h	2010/06/17 12:48:55	1.57
+++ LVM2/lib/locking/locking.h	2010/08/17 19:25:05	1.58
@@ -93,14 +93,16 @@
 #define LCK_LOCAL	0x00000040U	/* Don't propagate to other nodes */
 #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
+#define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
 
 /*
- * Additional lock bits for cluster communication
+ * Additional lock bits for cluster communication via args[1]
  */
-#define LCK_PARTIAL_MODE        0x00000001U	/* Partial activation? */
-#define LCK_MIRROR_NOSYNC_MODE	0x00000002U	/* Mirrors don't require sync */
-#define LCK_DMEVENTD_MONITOR_MODE	0x00000004U	/* Register with dmeventd */
-#define LCK_CONVERT		0x00000008U	/* Convert existing lock */
+#define LCK_PARTIAL_MODE        	0x01	/* Partial activation? */
+#define LCK_MIRROR_NOSYNC_MODE		0x02	/* Mirrors don't require sync */
+#define LCK_DMEVENTD_MONITOR_MODE	0x04	/* Register with dmeventd */
+#define LCK_CONVERT			0x08	/* Convert existing lock */
+#define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
 
 /*
  * Special cases of VG locks.
@@ -148,7 +150,9 @@
 	} while (0)
 
 #define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
+#define resume_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME | LCK_ORIGIN_ONLY)
 #define suspend_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD)
+#define suspend_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD | LCK_ORIGIN_ONLY)
 #define deactivate_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE)
 #define activate_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_ACTIVATE | LCK_HOLD)
 #define activate_lv_excl(cmd, lv)	\
--- LVM2/lib/locking/no_locking.c	2010/08/17 16:25:33	1.23
+++ LVM2/lib/locking/no_locking.c	2010/08/17 19:25:05	1.24
@@ -44,13 +44,11 @@
 		case LCK_NULL:
 			return lv_deactivate(cmd, resource);
 		case LCK_UNLOCK:
-			// FIXME Set origin_only
-			return lv_resume_if_active(cmd, resource, 0);
+			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0);
 		case LCK_READ:
 			return lv_activate_with_filter(cmd, resource, 0);
 		case LCK_WRITE:
-			// FIXME Set origin_only
-			return lv_suspend_if_active(cmd, resource, 0);
+			return lv_suspend_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1 : 0);
 		case LCK_EXCL:
 			return lv_activate_with_filter(cmd, resource, 1);
 		default:
--- LVM2/lib/metadata/mirror.c	2010/08/17 16:25:33	1.133
+++ LVM2/lib/metadata/mirror.c	2010/08/17 19:25:05	1.134
@@ -934,7 +934,7 @@
 		return 0;
 	}
 
-	if (!suspend_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
+	if (!suspend_lv_origin(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Failed to lock %s", mirrored_seg->lv->name);
 		vg_revert(mirrored_seg->lv->vg);
 		return 0;
@@ -969,7 +969,7 @@
 		return 0;
 	}
 
-	if (!resume_lv(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
+	if (!resume_lv_origin(mirrored_seg->lv->vg->cmd, mirrored_seg->lv)) {
 		log_error("Problem reactivating %s", mirrored_seg->lv->name);
 		return 0;
 	}
--- LVM2/tools/lvchange.c	2010/08/17 16:25:35	1.124
+++ LVM2/tools/lvchange.c	2010/08/17 19:25:05	1.125
@@ -162,6 +162,7 @@
 static int lvchange_refresh(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	log_verbose("Refreshing logical volume \"%s\" (if active)", lv->name);
+
 	return lv_refresh(cmd, lv);
 }
 


