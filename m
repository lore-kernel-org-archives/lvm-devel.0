From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2011 22:43:43 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20110927224343.23639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-27 22:43:42

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c activate.h dev_manager.c 
	lib/locking    : cluster_locking.c file_locking.c locking.c 
	                 locking.h no_locking.c 
	libdm          : libdm-deptree.c 
	tools          : pvmove.c 

Log message:
	Introduce revert_lv for better pvmove cleanup.
	(One further fix needed to remove the stray pvmove LVs left behind.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2142&r2=1.2143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.214&r2=1.215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.232&r2=1.233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/WHATS_NEW	2011/09/27 17:29:33	1.2142
+++ LVM2/WHATS_NEW	2011/09/27 22:43:40	1.2143
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Introduce revert_lv for better pvmove cleanup.
   Replace incomplete pvmove activation failure recovery code with a message.
   Abort if _finish_pvmove suspend_lvs fails instead of cleaning up incompletely.
   Change suspend_lvs to call vg_revert internally.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/09/24 20:50:36	1.124
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/09/27 22:43:40	1.125
@@ -406,7 +406,7 @@
 /* Resume the LV if it was active */
 static int do_resume_lv(char *resource, unsigned char lock_flags)
 {
-	int oldmode, origin_only, exclusive;
+	int oldmode, origin_only, exclusive, revert;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
@@ -416,8 +416,9 @@
 	}
 	origin_only = (lock_flags & LCK_ORIGIN_ONLY_MODE) ? 1 : 0;
 	exclusive = (oldmode == LCK_EXCL) ? 1 : 0;
+	revert = (lock_flags & LCK_REVERT_MODE) ? 1 : 0;
 
-	if (!lv_resume_if_active(cmd, resource, origin_only, exclusive))
+	if (!lv_resume_if_active(cmd, resource, origin_only, exclusive, revert))
 		return EIO;
 
 	return 0;
--- LVM2/lib/activate/activate.c	2011/09/26 10:17:51	1.214
+++ LVM2/lib/activate/activate.c	2011/09/27 22:43:40	1.215
@@ -190,7 +190,7 @@
 	return 1;
 }
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
-			unsigned origin_only, unsigned exclusive)
+			unsigned origin_only, unsigned exclusive, unsigned revert)
 {
 	return 1;
 }
@@ -1356,14 +1356,16 @@
 		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Resuming %s%s.", lv->name, laopts->origin_only ? " without snapshots" : "");
+		_skip("Resuming %s%s%s.", lv->name, laopts->origin_only ? " without snapshots" : "",
+		      laopts->revert ? " (reverting)" : "");
 		r = 1;
 		goto out;
 	}
 
-	log_debug("Resuming LV %s/%s%s%s.", lv->vg->name, lv->name,
+	log_debug("Resuming LV %s/%s%s%s%s.", lv->vg->name, lv->name,
 		  error_if_not_active ? "" : " if active",
-		  laopts->origin_only ? " without snapshots" : "");
+		  laopts->origin_only ? " without snapshots" : "",
+		  laopts->revert ? " (reverting)" : "");
 
 	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
@@ -1395,7 +1397,7 @@
 
 /* Returns success if the device is not active */
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
-			unsigned origin_only, unsigned exclusive)
+			unsigned origin_only, unsigned exclusive, unsigned revert)
 {
 	struct lv_activate_opts laopts = {
 		.origin_only = origin_only,
@@ -1404,7 +1406,8 @@
 		 * non-clustered target should be used.  This only happens
 		 * if exclusive is set.
 		 */
-		.exclusive = exclusive
+		.exclusive = exclusive,
+		.revert = revert
 	};
 
 	return _lv_resume(cmd, lvid_s, &laopts, 0);
--- LVM2/lib/activate/activate.h	2011/09/22 17:33:51	1.80
+++ LVM2/lib/activate/activate.h	2011/09/27 22:43:40	1.81
@@ -34,6 +34,7 @@
 	int exclusive;
 	int origin_only;
 	int no_merging;
+	unsigned revert;
 };
 
 /* target attribute flags */
@@ -63,7 +64,7 @@
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
-			unsigned origin_only, unsigned exclusive);
+			unsigned origin_only, unsigned exclusive, unsigned revert);
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive);
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s,
 			    int exclusive);
--- LVM2/lib/activate/dev_manager.c	2011/09/22 17:39:57	1.232
+++ LVM2/lib/activate/dev_manager.c	2011/09/27 22:43:41	1.233
@@ -1590,7 +1590,7 @@
 					     layer ? UINT32_C(0) : (uint32_t) lv->major,
 					     layer ? UINT32_C(0) : (uint32_t) lv->minor,
 					     _read_only_lv(lv),
-					     (lv->vg->status & PRECOMMITTED) ? 1 : 0,
+					     ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
 					     lvlayer,
 					     _get_udev_flags(dm, lv, layer))))
 		return_0;
--- LVM2/lib/locking/cluster_locking.c	2011/08/30 14:55:17	1.58
+++ LVM2/lib/locking/cluster_locking.c	2011/09/27 22:43:41	1.59
@@ -327,6 +327,9 @@
 	if (flags & LCK_ORIGIN_ONLY)
 		args[1] |= LCK_ORIGIN_ONLY_MODE;
 
+	if (flags & LCK_REVERT)
+		args[1] |= LCK_REVERT_MODE;
+
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
--- LVM2/lib/locking/file_locking.c	2011/08/09 11:44:57	1.60
+++ LVM2/lib/locking/file_locking.c	2011/09/27 22:43:41	1.61
@@ -257,6 +257,7 @@
 {
 	char lockfile[PATH_MAX];
 	unsigned origin_only = (flags & LCK_ORIGIN_ONLY) ? 1 : 0;
+	unsigned revert = (flags & LCK_REVERT) ? 1 : 0;
 
 	switch (flags & LCK_SCOPE_MASK) {
 	case LCK_VG:
@@ -292,8 +293,8 @@
 	case LCK_LV:
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
-			log_very_verbose("Unlocking LV %s%s", resource, origin_only ? " without snapshots" : "");
-			if (!lv_resume_if_active(cmd, resource, origin_only, 0))
+			log_very_verbose("Unlocking LV %s%s%s", resource, origin_only ? " without snapshots" : "", revert ? " (reverting)" : "");
+			if (!lv_resume_if_active(cmd, resource, origin_only, 0, revert))
 				return 0;
 			break;
 		case LCK_NULL:
--- LVM2/lib/locking/locking.c	2011/09/27 17:09:43	1.99
+++ LVM2/lib/locking/locking.c	2011/09/27 22:43:41	1.100
@@ -493,6 +493,20 @@
 	return r;
 }
 
+/* Unlock and revert list of LVs */
+int revert_lvs(struct cmd_context *cmd, struct dm_list *lvs)
+{
+	struct lv_list *lvl;
+	int r = 1;
+
+	dm_list_iterate_items(lvl, lvs)
+		if (!revert_lv(cmd, lvl->lv)) {
+			r = 0;
+			stack;
+		}
+
+	return r;
+}
 /*
  * Lock a list of LVs.
  * On failure to lock any LV, calls vg_revert() if vg_to_revert is set and 
@@ -511,7 +525,7 @@
 				vg_revert(vg_to_revert);
 			dm_list_uniterate(lvh, lvs, &lvl->list) {
 				lvl = dm_list_item(lvh, struct lv_list);
-				if (!resume_lv(cmd, lvl->lv))
+				if (!revert_lv(cmd, lvl->lv))
 					stack;
 			}
 
--- LVM2/lib/locking/locking.h	2011/09/27 17:09:43	1.68
+++ LVM2/lib/locking/locking.h	2011/09/27 22:43:41	1.69
@@ -97,6 +97,7 @@
 #define LCK_CLUSTER_VG	0x00000080U	/* VG is clustered */
 #define LCK_CACHE	0x00000100U	/* Operation on cache only using P_ lock */
 #define LCK_ORIGIN_ONLY	0x00000200U	/* Operation should bypass any snapshots */
+#define LCK_REVERT	0x00000400U	/* Revert any incomplete change */
 
 /*
  * Additional lock bits for cluster communication via args[1]
@@ -107,6 +108,7 @@
 #define LCK_CONVERT			0x08	/* Convert existing lock */
 #define LCK_ORIGIN_ONLY_MODE		0x20	/* Same as above */
 #define LCK_TEST_MODE			0x10    /* Test mode: No activation */
+#define LCK_REVERT_MODE			0x40	/* Remove inactive tables */
 
 /*
  * Special cases of VG locks.
@@ -164,6 +166,7 @@
 
 #define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
 #define resume_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME | LCK_ORIGIN_ONLY)
+#define revert_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME | LCK_REVERT)
 #define suspend_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD)
 #define suspend_lv_origin(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD | LCK_ORIGIN_ONLY)
 #define deactivate_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_DEACTIVATE)
@@ -191,6 +194,7 @@
 int suspend_lvs(struct cmd_context *cmd, struct dm_list *lvs,
 		struct volume_group *vg_to_revert);
 int resume_lvs(struct cmd_context *cmd, struct dm_list *lvs);
+int revert_lvs(struct cmd_context *cmd, struct dm_list *lvs);
 int activate_lvs(struct cmd_context *cmd, struct dm_list *lvs, unsigned exclusive);
 
 /* Interrupt handling */
--- LVM2/lib/locking/no_locking.c	2011/08/09 11:44:57	1.29
+++ LVM2/lib/locking/no_locking.c	2011/09/27 22:43:41	1.30
@@ -46,7 +46,7 @@
 		case LCK_NULL:
 			return lv_deactivate(cmd, resource);
 		case LCK_UNLOCK:
-			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0);
+			return lv_resume_if_active(cmd, resource, (flags & LCK_ORIGIN_ONLY) ? 1: 0, 0, (flags & LCK_REVERT) ? 1 : 0);
 		case LCK_READ:
 			return lv_activate_with_filter(cmd, resource, 0);
 		case LCK_WRITE:
--- LVM2/libdm/libdm-deptree.c	2011/09/26 10:17:52	1.112
+++ LVM2/libdm/libdm-deptree.c	2011/09/27 22:43:41	1.113
@@ -610,6 +610,8 @@
 	if (!info->exists || !info->inactive_table)
 		return 1;
 
+// FIXME Get inactive deps.  If any dev referenced has 1 opener and no live table, remove it after the clear.
+
 	log_verbose("Clearing inactive table %s (%" PRIu32 ":%" PRIu32 ")",
 		    name, info->major, info->minor);
 
--- LVM2/tools/pvmove.c	2011/09/27 17:29:33	1.89
+++ LVM2/tools/pvmove.c	2011/09/27 22:43:42	1.90
@@ -370,13 +370,19 @@
 
 	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed, vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
-		goto out;
+		if (!first_time && !revert_lv(cmd, lv_mirr))
+			stack;
+		return 0;
 	}
 
 	/* Commit on-disk metadata */
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
-		goto out;
+		if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
+			stack;
+		if (!first_time && !revert_lv(cmd, lv_mirr))
+			stack;
+		return 0;
 	}
 
 	/* Activate the temporary mirror LV */
@@ -403,7 +409,9 @@
 	if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
 		r = 0;
 
-	backup(vg);
+	if (r)
+		backup(vg);
+
 	return r;
 }
 
@@ -546,6 +554,8 @@
 	/* Suspend LVs changed (implicitly suspends lv_mirr) */
 	if (!suspend_lvs(cmd, lvs_changed, vg)) {
 		log_error("ABORTING: Locking LVs to remove temporary mirror failed");
+		if (!revert_lv(cmd, lv_mirr))
+			stack;
 		return 0;
 	}
 
@@ -553,9 +563,9 @@
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Failed to write new data locations "
 			  "to disk.");
-		if (!resume_lv(cmd, lv_mirr))
+		if (!revert_lv(cmd, lv_mirr))
 			stack;
-		if (!resume_lvs(cmd, lvs_changed))
+		if (!revert_lvs(cmd, lvs_changed))
 			stack;
 		return 0;
 	}


