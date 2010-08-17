From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Aug 2010 16:25:40 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20100817162540.11031.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-17 16:25:36

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c lvm-functions.c lvm-functions.h 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	lib/display    : display.c 
	lib/locking    : file_locking.c no_locking.c 
	lib/metadata   : lv_manip.c mirror.c 
	lib/mirror     : mirrored.c 
	lib/report     : report.c 
	liblvm         : lvm_lv.c 
	tools          : lvchange.c lvconvert.c lvresize.c lvscan.c 
	                 vgchange.c vgconvert.c vgreduce.c 

Log message:
	Allow internal suspend and resume of origin without its snapshots.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1707&r2=1.1708
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.199&r2=1.200
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.231&r2=1.232
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvscan.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/WHATS_NEW	2010/08/17 01:51:12	1.1707
+++ LVM2/WHATS_NEW	2010/08/17 16:25:32	1.1708
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Allow internal suspend and resume of origin without its snapshots.
   Fix dev_manager_transient to access -real device not snapshot-origin.
   Monitor origin -real device below snapshot instead of overlay device.
   Don't really change monitoring status when in test mode.
--- LVM2/daemons/clvmd/clvmd.c	2010/08/03 13:06:35	1.76
+++ LVM2/daemons/clvmd/clvmd.c	2010/08/17 16:25:32	1.77
@@ -1885,7 +1885,7 @@
 	pthread_sigmask(SIG_BLOCK, &ss, NULL);
 
 	/* Initialise the interface to liblvm */
-	init_lvm(lvm_params->using_gulm, lvm_params->argv);
+	init_clvm(lvm_params->using_gulm, lvm_params->argv);
 
 	/* Allow others to get moving */
 	pthread_mutex_unlock(&lvm_start_mutex);
--- LVM2/daemons/clvmd/lvm-functions.c	2010/08/03 13:06:35	1.97
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/08/17 16:25:32	1.98
@@ -214,7 +214,7 @@
 }
 
 /* Gets a real lock and keeps the info in the hash table */
-int hold_lock(char *resource, int mode, int flags)
+static int hold_lock(char *resource, int mode, int flags)
 {
 	int status;
 	int saved_errno;
@@ -269,7 +269,7 @@
 }
 
 /* Unlock and remove it from the hash table */
-int hold_unlock(char *resource)
+static int hold_unlock(char *resource)
 {
 	struct lv_info *lvi;
 	int status;
@@ -350,12 +350,14 @@
 	}
 
 	/* If it's suspended then resume it */
-	if (!lv_info_by_lvid(cmd, resource, &lvi, 0, 0))
+	// FIXME Set origin_only
+	if (!lv_info_by_lvid(cmd, resource, 0, &lvi, 0, 0))
 		goto error;
 
 	if (lvi.suspended) {
 		memlock_inc(cmd);
-		if (!lv_resume(cmd, resource)) {
+		// FIXME Set origin_only
+		if (!lv_resume(cmd, resource, 0)) {
 			memlock_dec(cmd);
 			goto error;
 		}
@@ -385,7 +387,8 @@
 		return 0;	/* We don't need to do anything */
 	}
 
-	if (!lv_resume_if_active(cmd, resource))
+	// FIXME Set origin_only
+	if (!lv_resume_if_active(cmd, resource, 0))
 		return EIO;
 
 	return 0;
@@ -405,14 +408,14 @@
 	}
 
 	/* Only suspend it if it exists */
-	if (!lv_info_by_lvid(cmd, resource, &lvi, 0, 0))
+	// FIXME Set origin_only
+	if (!lv_info_by_lvid(cmd, resource, 0, &lvi, 0, 0))
+		return EIO;
+
+	// FIXME Set origin_only
+	if (lvi.exists && !lv_suspend_if_active(cmd, resource, 0))
 		return EIO;
 
-	if (lvi.exists) {
-		if (!lv_suspend_if_active(cmd, resource)) {
-			return EIO;
-		}
-	}
 	return 0;
 }
 
@@ -571,7 +574,8 @@
 			struct lvinfo lvi;
 
 			pthread_mutex_lock(&lvm_lock);
-			status = lv_info_by_lvid(cmd, resource, &lvi, 0, 0);
+			// FIXME Set origin_only
+			status = lv_info_by_lvid(cmd, resource, 0, &lvi, 0, 0);
 			pthread_mutex_unlock(&lvm_lock);
 			if (!status)
 				return EIO;
@@ -579,10 +583,8 @@
 			if (lvi.exists) {
 				if (hold_lock(resource, LCK_READ, LCKF_CONVERT))
 					return errno;
-			} else {
-				if (hold_unlock(resource))
-					return errno;
-			}
+			} else if (hold_unlock(resource))
+				return errno;
 		}
 	}
 	return 0;
@@ -882,7 +884,7 @@
 }
 
 /* Called to initialise the LVM context of the daemon */
-int init_lvm(int using_gulm, char **argv)
+int init_clvm(int using_gulm, char **argv)
 {
 	if (!(cmd = create_toolcontext(1, NULL))) {
 		log_error("Failed to allocate command context");
--- LVM2/daemons/clvmd/lvm-functions.h	2010/04/20 14:07:38	1.13
+++ LVM2/daemons/clvmd/lvm-functions.h	2010/08/17 16:25:32	1.14
@@ -27,15 +27,14 @@
 			char *resource);
 extern int do_check_lvm1(const char *vgname);
 extern int do_refresh_cache(void);
-extern int init_lvm(int using_gulm, char **argv);
+extern int init_clvm(int using_gulm, char **argv);
 extern void destroy_lvm(void);
 extern void init_lvhash(void);
 extern void destroy_lvhash(void);
 extern void lvm_do_backup(const char *vgname);
-extern int hold_unlock(char *resource);
-extern int hold_lock(char *resource, int mode, int flags);
 extern char *get_last_lvm_error(void);
 extern void do_lock_vg(unsigned char command, unsigned char lock_flags,
 		      char *resource);
 extern struct dm_hash_node *get_next_excl_lock(struct dm_hash_node *v, char **name);
+
 #endif
--- LVM2/lib/activate/activate.c	2010/08/17 01:16:41	1.176
+++ LVM2/lib/activate/activate.c	2010/08/17 16:25:32	1.177
@@ -147,12 +147,13 @@
 {
 	return 0;
 }
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
-	    int with_open_count, int with_read_ahead)
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, unsigned origin_only,
+	    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	return 0;
 }
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
+		    unsigned origin_only,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	return 0;
@@ -176,10 +177,12 @@
 {
 	return 0;
 }
+/******
 int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 {
 	return 1;
 }
+*******/
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s)
 {
 	return 1;
@@ -451,7 +454,7 @@
 /*
  * Returns 1 if info structure populated, else 0 on failure.
  */
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, unsigned origin_only,
 	    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	struct dm_info dminfo;
@@ -459,7 +462,7 @@
 	if (!activation())
 		return 0;
 
-	if (!dev_manager_info(lv->vg->cmd->mem, lv, with_open_count,
+	if (!dev_manager_info(lv->vg->cmd->mem, lv, origin_only ? "real" : NULL, with_open_count,
 			      with_read_ahead, &dminfo, &info->read_ahead))
 		return_0;
 
@@ -476,6 +479,7 @@
 }
 
 int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
+		    unsigned origin_only,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead)
 {
 	int r;
@@ -484,7 +488,10 @@
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		return 0;
 
-	r = lv_info(cmd, lv, info, with_open_count, with_read_ahead);
+	if (!lv_is_origin(lv))
+		origin_only = 0;
+
+	r = lv_info(cmd, lv, origin_only, info, with_open_count, with_read_ahead);
 	vg_release(lv->vg);
 
 	return r;
@@ -554,7 +561,7 @@
 	if (!activation())
 		return 0;
 
-	if (!lv_info(cmd, lv, &info, 0, 0))
+	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		return_0;
 
 	if (!info.exists)
@@ -576,7 +583,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 0, 0)) {
+	if (!lv_info(cmd, lv, 0, &info, 0, 0)) {
 		stack;
 		return -1;
 	}
@@ -588,7 +595,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 1, 0)) {
+	if (!lv_info(cmd, lv, 0, &info, 1, 0)) {
 		stack;
 		return -1;
 	}
@@ -596,7 +603,7 @@
 	return info.open_count;
 }
 
-static int _lv_activate_lv(struct logical_volume *lv)
+static int _lv_activate_lv(struct logical_volume *lv, unsigned origin_only)
 {
 	int r;
 	struct dev_manager *dm;
@@ -604,14 +611,14 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_activate(dm, lv)))
+	if (!(r = dev_manager_activate(dm, lv, origin_only)))
 		stack;
 
 	dev_manager_destroy(dm);
 	return r;
 }
 
-static int _lv_preload(struct logical_volume *lv, int *flush_required)
+static int _lv_preload(struct logical_volume *lv, unsigned origin_only, int *flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -619,7 +626,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_preload(dm, lv, flush_required)))
+	if (!(r = dev_manager_preload(dm, lv, origin_only, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -641,7 +648,7 @@
 	return r;
 }
 
-static int _lv_suspend_lv(struct logical_volume *lv, int lockfs, int flush_required)
+static int _lv_suspend_lv(struct logical_volume *lv, unsigned origin_only, int lockfs, int flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -649,7 +656,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
 		return_0;
 
-	if (!(r = dev_manager_suspend(dm, lv, lockfs, flush_required)))
+	if (!(r = dev_manager_suspend(dm, lv, origin_only, lockfs, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -841,8 +848,8 @@
  * Returns 0 if an attempt to (un)monitor the device failed.
  * Returns 1 otherwise.
  */
-int monitor_dev_for_events(struct cmd_context *cmd,
-			    struct logical_volume *lv, int monitor)
+int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
+			   unsigned origin_only, int monitor)
 {
 #ifdef DMEVENTD
 	int i, pending = 0, monitored;
@@ -868,17 +875,17 @@
 	 * not the actual LV itself.
 	 */
 	if (lv_is_cow(lv) && !lv_is_merging_cow(lv))
-		return monitor_dev_for_events(cmd, lv->snapshot->lv, monitor);
+		return monitor_dev_for_events(cmd, lv->snapshot->lv, 0, monitor);
 
 	/*
 	 * In case this LV is a snapshot origin, we instead monitor
 	 * each of its respective snapshots.  The origin itself may
 	 * also need to be monitored if it is a mirror, for example.
 	 */
-	if (lv_is_origin(lv))
+	if (!origin_only && lv_is_origin(lv))
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
-				    struct lv_segment, origin_list)->cow, monitor))
+				    struct lv_segment, origin_list)->cow, 0, monitor))
 				r = 0;
 
 	/*
@@ -888,7 +895,7 @@
 	if ((seg = first_seg(lv)) != NULL && seg->log_lv != NULL &&
 	    (log_seg = first_seg(seg->log_lv)) != NULL &&
 	    seg_is_mirrored(log_seg))
-		if (!monitor_dev_for_events(cmd, seg->log_lv, monitor))
+		if (!monitor_dev_for_events(cmd, seg->log_lv, 0, monitor))
 			r = 0;
 
 	dm_list_iterate(tmp, &lv->segments) {
@@ -898,7 +905,7 @@
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			if (!monitor_dev_for_events(cmd, seg_lv(seg, s),
+			if (!monitor_dev_for_events(cmd, seg_lv(seg, s), 0,
 						    monitor)) {
 				log_error("Failed to %smonitor %s",
 					  monitor ? "" : "un",
@@ -979,7 +986,7 @@
 }
 
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
-		       int error_if_not_suspended)
+		       unsigned origin_only, int error_if_not_suspended)
 {
 	struct logical_volume *lv = NULL, *lv_pre = NULL;
 	struct lvinfo info;
@@ -995,13 +1002,17 @@
 	if (!(lv_pre = lv_from_lvid(cmd, lvid_s, 1)))
 		goto_out;
 
+	/* Ignore origin_only unless LV is origin in both old and new metadata */
+	if (!lv_is_origin(lv) || !lv_is_origin(lv_pre))
+		origin_only = 0;
+
 	if (test_mode()) {
-		_skip("Suspending '%s'.", lv->name);
+		_skip("Suspending %s%s.", lv->name, origin_only ? " origin without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, &info, 0, 0))
+	if (!lv_info(cmd, lv, origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || info.suspended) {
@@ -1020,22 +1031,23 @@
 
 	/* If VG was precommitted, preload devices for the LV */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
-		if (!_lv_preload(lv_pre, &flush_required)) {
+		if (!_lv_preload(lv_pre, origin_only, &flush_required)) {
 			/* FIXME Revert preloading */
 			goto_out;
 		}
 	}
 
-	if (!monitor_dev_for_events(cmd, lv, 0))
+	if (!monitor_dev_for_events(cmd, lv, origin_only, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
 	memlock_inc(cmd);
 
-	if (lv_is_origin(lv_pre) || lv_is_cow(lv_pre))
+	if (!origin_only &&
+	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
-	if (!_lv_suspend_lv(lv, lockfs, flush_required)) {
+	if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
 		memlock_dec(cmd);
 		fs_unlock();
 		goto out;
@@ -1054,17 +1066,21 @@
 }
 
 /* Returns success if the device is not active */
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s)
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_suspend(cmd, lvid_s, 0);
+	return _lv_suspend(cmd, lvid_s, origin_only, 0);
 }
 
+/* No longer used */
+/***********
 int lv_suspend(struct cmd_context *cmd, const char *lvid_s)
 {
 	return _lv_suspend(cmd, lvid_s, 1);
 }
+***********/
 
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
+		      unsigned origin_only,
 		      int error_if_not_active)
 {
 	struct logical_volume *lv;
@@ -1077,13 +1093,16 @@
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
 		goto_out;
 
+	if (!lv_is_origin(lv))
+		origin_only = 0;
+
 	if (test_mode()) {
-		_skip("Resuming '%s'.", lv->name);
+		_skip("Resuming %s%s.", lv->name, origin_only ? " without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, &info, 0, 0))
+	if (!lv_info(cmd, lv, origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || !info.suspended) {
@@ -1093,13 +1112,13 @@
 		goto out;
 	}
 
-	if (!_lv_activate_lv(lv))
+	if (!_lv_activate_lv(lv, origin_only))
 		goto_out;
 
 	memlock_dec(cmd);
 	fs_unlock();
 
-	if (!monitor_dev_for_events(cmd, lv, 1))
+	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
 		stack;
 
 	r = 1;
@@ -1111,14 +1130,14 @@
 }
 
 /* Returns success if the device is not active */
-int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s)
+int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_resume(cmd, lvid_s, 0);
+	return _lv_resume(cmd, lvid_s, origin_only, 0);
 }
 
-int lv_resume(struct cmd_context *cmd, const char *lvid_s)
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_resume(cmd, lvid_s, 1);
+	return _lv_resume(cmd, lvid_s, origin_only, 1);
 }
 
 static int _lv_has_open_snapshots(struct logical_volume *lv)
@@ -1128,7 +1147,7 @@
 	int r = 0;
 
 	dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list) {
-		if (!lv_info(lv->vg->cmd, snap_seg->cow, &info, 1, 0)) {
+		if (!lv_info(lv->vg->cmd, snap_seg->cow, 0, &info, 1, 0)) {
 			r = 1;
 			continue;
 		}
@@ -1162,7 +1181,7 @@
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, &info, 1, 0))
+	if (!lv_info(cmd, lv, 0, &info, 1, 0))
 		goto_out;
 
 	if (!info.exists) {
@@ -1185,7 +1204,7 @@
 
 	lv_calculate_readahead(lv, NULL);
 
-	if (!monitor_dev_for_events(cmd, lv, 0))
+	if (!monitor_dev_for_events(cmd, lv, 0, 0))
 		stack;
 
 	memlock_inc(cmd);
@@ -1193,7 +1212,7 @@
 	memlock_dec(cmd);
 	fs_unlock();
 
-	if (!lv_info(cmd, lv, &info, 1, 0) || info.exists)
+	if (!lv_info(cmd, lv, 0, &info, 1, 0) || info.exists)
 		r = 0;
 out:
 	if (lv) {
@@ -1270,7 +1289,7 @@
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, &info, 0, 0))
+	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
 
 	if (info.exists && !info.suspended && info.live_table) {
@@ -1287,12 +1306,12 @@
 		lv->status |= ACTIVATE_EXCL;
 
 	memlock_inc(cmd);
-	if (!(r = _lv_activate_lv(lv)))
+	if (!(r = _lv_activate_lv(lv, 0)))
 		stack;
 	memlock_dec(cmd);
 	fs_unlock();
 
-	if (r && !monitor_dev_for_events(cmd, lv, 1))
+	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
 		stack;
 
 out:
--- LVM2/lib/activate/activate.h	2010/08/17 01:16:41	1.70
+++ LVM2/lib/activate/activate.h	2010/08/17 16:25:32	1.71
@@ -53,10 +53,10 @@
 void activation_release(void);
 void activation_exit(void);
 
-int lv_suspend(struct cmd_context *cmd, const char *lvid_s);
-int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s);
-int lv_resume(struct cmd_context *cmd, const char *lvid_s);
-int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s);
+/* int lv_suspend(struct cmd_context *cmd, const char *lvid_s); */
+int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
+int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
+int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only);
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive);
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s,
 			    int exclusive);
@@ -67,9 +67,10 @@
 /*
  * Returns 1 if info structure has been populated, else 0.
  */
-int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, struct lvinfo *info,
+int lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
+	    unsigned origin_only, struct lvinfo *info,
 	    int with_open_count, int with_read_ahead);
-int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s,
+int lv_info_by_lvid(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only,
 		    struct lvinfo *info, int with_open_count, int with_read_ahead);
 
 /*
@@ -99,8 +100,8 @@
 int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
 		       const char *layer, const char *target_type);
 
-int monitor_dev_for_events(struct cmd_context *cmd,
-			    struct logical_volume *lv, int do_reg);
+int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
+			   unsigned origin_only, int do_reg);
 
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
--- LVM2/lib/activate/dev_manager.c	2010/08/17 01:51:12	1.199
+++ LVM2/lib/activate/dev_manager.c	2010/08/17 16:25:33	1.200
@@ -222,19 +222,20 @@
 }
 
 int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
+		     const char *layer,
 		     int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead)
 {
 	char *dlid, *name;
 	int r;
 
-	if (!(name = build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
+	if (!(name = build_dm_name(mem, lv->vg->name, lv->name, layer))) {
 		log_error("name build failed for %s", lv->name);
 		return 0;
 	}
 
-	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, NULL))) {
-		log_error("dlid build failed for %s", lv->name);
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer))) {
+		log_error("dlid build failed for %s", name);
 		return 0;
 	}
 
@@ -559,11 +560,11 @@
 	char *type = NULL;
 	char *params = NULL;
 	char *dlid = NULL;
-	char *suffix = lv_is_origin(lv) ? "real" : NULL;
+	const char *layer = lv_is_origin(lv) ? "real" : NULL;
 	const struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, suffix)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(0, dlid, NULL, DM_DEVICE_STATUS, 0, 0)))
@@ -714,17 +715,17 @@
 {
 	char *name;
 	const char *dlid;
-	const char *suffix = (lv_is_origin(lv)) ? "real" : NULL;
+	const char *layer = (lv_is_origin(lv)) ? "real" : NULL;
 
 	/*
 	 * Build a name for the top layer.
 	 */
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, suffix)))
+	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, suffix))) {
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
@@ -1014,16 +1015,16 @@
 /*
  * Add LV and any known dependencies
  */
-static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv)
+static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv, unsigned origin_only)
 {
-	if (!_add_dev_to_dtree(dm, dtree, lv, NULL))
+	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
 
 	/* FIXME Can we avoid doing this every time? */
 	if (!_add_dev_to_dtree(dm, dtree, lv, "real"))
 		return_0;
 
-	if (!_add_dev_to_dtree(dm, dtree, lv, "cow"))
+	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, "cow"))
 		return_0;
 
 	if ((lv->status & MIRRORED) && first_seg(lv)->log_lv &&
@@ -1038,7 +1039,7 @@
 	return 1;
 }
 
-static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv)
+static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only)
 {
 	struct dm_tree *dtree;
 	struct dm_list *snh, *snht;
@@ -1050,19 +1051,20 @@
 		return NULL;
 	}
 
-	if (!_add_lv_to_dtree(dm, dtree, lv))
+	if (!_add_lv_to_dtree(dm, dtree, lv, origin_only))
 		goto_bad;
 
 	/* Add any snapshots of this LV */
-	dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
-		if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow))
-			goto_bad;
+	if (!origin_only)
+		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
+			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
+				goto_bad;
 
 	/* Add any LVs used by segments in this LV */
 	dm_list_iterate_items(seg, &lv->segments)
 		for (s = 0; s < seg->area_count; s++)
 			if (seg_type(seg, s) == AREA_LV && seg_lv(seg, s)) {
-				if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, s)))
+				if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, s), 0))
 					goto_bad;
 			}
 
@@ -1622,14 +1624,15 @@
 	return 1;
 }
 
-static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, action_t action)
+static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
+			unsigned origin_only, action_t action)
 {
 	struct dm_tree *dtree;
 	struct dm_tree_node *root;
 	char *dlid;
 	int r = 0;
 
-	if (!(dtree = _create_partial_dtree(dm, lv)))
+	if (!(dtree = _create_partial_dtree(dm, lv, origin_only)))
 		return_0;
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
@@ -1637,7 +1640,7 @@
 		goto out;
 	}
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, origin_only ? "real" : NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
@@ -1669,7 +1672,7 @@
 	case PRELOAD:
 	case ACTIVATE:
 		/* Add all required new devices to tree */
-		if (!_add_new_lv_to_dtree(dm, dtree, lv, NULL))
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, origin_only ? "real" : NULL))
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
@@ -1710,22 +1713,24 @@
 	return r;
 }
 
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv)
+/* origin_only may only be set if we are resuming (not activating) an origin LV */
+int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only)
 {
-	if (!_tree_action(dm, lv, ACTIVATE))
+	if (!_tree_action(dm, lv, origin_only, ACTIVATE))
 		return_0;
 
-	return _tree_action(dm, lv, CLEAN);
+	return _tree_action(dm, lv, origin_only, CLEAN);
 }
 
+/* origin_only may only be set if we are resuming (not activating) an origin LV */
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
-			int *flush_required)
+			unsigned origin_only, int *flush_required)
 {
 	/* FIXME Update the pvmove implementation! */
 	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
 		return 1;
 
-	if (!_tree_action(dm, lv, PRELOAD))
+	if (!_tree_action(dm, lv, origin_only, PRELOAD))
 		return 0;
 
 	*flush_required = dm->flush_required;
@@ -1737,17 +1742,17 @@
 {
 	int r;
 
-	r = _tree_action(dm, lv, DEACTIVATE);
+	r = _tree_action(dm, lv, 0, DEACTIVATE);
 
 	return r;
 }
 
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			int lockfs, int flush_required)
+			unsigned origin_only, int lockfs, int flush_required)
 {
 	dm->flush_required = flush_required;
 
-	return _tree_action(dm, lv, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
+	return _tree_action(dm, lv, origin_only, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
 }
 
 /*
--- LVM2/lib/activate/dev_manager.h	2010/05/24 15:32:20	1.33
+++ LVM2/lib/activate/dev_manager.h	2010/08/17 16:25:33	1.34
@@ -41,6 +41,7 @@
  * unsuspended until the snapshot is also created.)
  */
 int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
+		     const char *layer,
 		     int with_open_count, int with_read_ahead,
 		     struct dm_info *info, uint32_t *read_ahead);
 int dev_manager_snapshot_percent(struct dev_manager *dm,
@@ -52,10 +53,10 @@
 			       float *percent, percent_range_t *percent_range,
 			       uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			int lockfs, int flush_required);
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv);
+			unsigned origin_only, int lockfs, int flush_required);
+int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only);
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
-			int *flush_required);
+			unsigned origin_only, int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv);
 
--- LVM2/lib/display/display.c	2010/07/09 15:34:42	1.111
+++ LVM2/lib/display/display.c	2010/08/17 16:25:33	1.112
@@ -452,7 +452,7 @@
 {
 	int inkernel;
 	struct lvinfo info;
-	inkernel = lv_info(lv->vg->cmd, lv, &info, 1, 0) && info.exists;
+	inkernel = lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists;
 
 	log_print("%s%s/%s:%s:%" PRIu64 ":%d:-1:%d:%" PRIu64 ":%d:-1:%d:%d:%d:%d",
 		  lv->vg->cmd->dev_dir,
@@ -481,7 +481,7 @@
 	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid)))
 		return_0;
 
-	inkernel = lv_info(cmd, lv, &info, 1, 1) && info.exists;
+	inkernel = lv_info(cmd, lv, 0, &info, 1, 1) && info.exists;
 
 	log_print("--- Logical volume ---");
 
--- LVM2/lib/locking/file_locking.c	2010/08/03 13:06:35	1.48
+++ LVM2/lib/locking/file_locking.c	2010/08/17 16:25:33	1.49
@@ -279,7 +279,8 @@
 		switch (flags & LCK_TYPE_MASK) {
 		case LCK_UNLOCK:
 			log_very_verbose("Unlocking LV %s", resource);
-			if (!lv_resume_if_active(cmd, resource))
+			// FIXME Set origin_only
+			if (!lv_resume_if_active(cmd, resource, 0))
 				return 0;
 			break;
 		case LCK_NULL:
@@ -297,7 +298,8 @@
 			break;
 		case LCK_WRITE:
 			log_very_verbose("Locking LV %s (W)", resource);
-			if (!lv_suspend_if_active(cmd, resource))
+			// FIXME Set origin_only
+			if (!lv_suspend_if_active(cmd, resource, 0))
 				return 0;
 			break;
 		case LCK_EXCL:
--- LVM2/lib/locking/no_locking.c	2010/07/09 15:34:45	1.22
+++ LVM2/lib/locking/no_locking.c	2010/08/17 16:25:33	1.23
@@ -44,11 +44,13 @@
 		case LCK_NULL:
 			return lv_deactivate(cmd, resource);
 		case LCK_UNLOCK:
-			return lv_resume_if_active(cmd, resource);
+			// FIXME Set origin_only
+			return lv_resume_if_active(cmd, resource, 0);
 		case LCK_READ:
 			return lv_activate_with_filter(cmd, resource, 0);
 		case LCK_WRITE:
-			return lv_suspend_if_active(cmd, resource);
+			// FIXME Set origin_only
+			return lv_suspend_if_active(cmd, resource, 0);
 		case LCK_EXCL:
 			return lv_activate_with_filter(cmd, resource, 1);
 		default:
--- LVM2/lib/metadata/lv_manip.c	2010/07/09 15:34:45	1.231
+++ LVM2/lib/metadata/lv_manip.c	2010/08/17 16:25:33	1.232
@@ -2237,7 +2237,7 @@
 
 	/* FIXME Ensure not referred to by another existing LVs */
 
-	if (lv_info(cmd, lv, &info, 1, 0)) {
+	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (info.open_count) {
 			log_error("Can't remove open logical volume \"%s\"",
 				  lv->name);
@@ -3109,7 +3109,7 @@
 				return 0;
 			}
 
-			if (!lv_info(cmd, org, &info, 0, 0)) {
+			if (!lv_info(cmd, org, 0, &info, 0, 0)) {
 				log_error("Check for existence of snapshot "
 					  "origin '%s' failed.", org->name);
 				return 0;
--- LVM2/lib/metadata/mirror.c	2010/08/16 18:02:14	1.132
+++ LVM2/lib/metadata/mirror.c	2010/08/17 16:25:33	1.133
@@ -292,14 +292,14 @@
 	}
 
 	/* If the LV is active, deactivate it first. */
-	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
+	if (lv_info(cmd, log_lv, 0, &info, 0, 0) && info.exists) {
 		(void)deactivate_lv(cmd, log_lv);
 		/*
 		 * FIXME: workaround to fail early
 		 * Ensure that log is really deactivated because deactivate_lv
 		 * on cluster do not fail if there is log_lv with different UUID.
 		 */
-		if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
+		if (lv_info(cmd, log_lv, 0, &info, 0, 0) && info.exists) {
 			log_error("Aborting. Unable to deactivate mirror log.");
 			goto revert_new_lv;
 		}
@@ -1587,7 +1587,7 @@
 	}
 
 	/* Had disk log, switch to core. */
-	if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
+	if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 		if (!lv_mirror_percent(cmd, lv, 0, &sync_percent,
 				       &percent_range, NULL)) {
 			log_error("Unable to determine mirror sync status.");
@@ -1787,7 +1787,7 @@
 	 * on remote nodes (even though it is inactive on this node)
 	 */
 	if (vg_is_clustered(lv->vg) &&
-	    !(lv_info(cmd, lv, &info, 0, 0) && info.exists)) {
+	    !(lv_info(cmd, lv, 0, &info, 0, 0) && info.exists)) {
 		log_error("Unable to convert the log of inactive "
 			  "cluster mirror %s", lv->name);
 		return 0;
--- LVM2/lib/mirror/mirrored.c	2010/08/17 01:16:41	1.77
+++ LVM2/lib/mirror/mirrored.c	2010/08/17 16:25:35	1.78
@@ -296,7 +296,7 @@
 	if (!strcmp(log_args[0], "disk")) {
 		char buf[32];
 		log = first_seg(lv)->log_lv;
-		lv_info(lv->vg->cmd, log, &info, 0, 0);
+		lv_info(lv->vg->cmd, log, 0, &info, 0, 0);
 		log_debug("Found mirror log at %d:%d", info.major, info.minor);
 		sprintf(buf, "%d:%d", info.major, info.minor);
 		if (strcmp(buf, log_args[1])) {
@@ -316,7 +316,7 @@
 
 	for (i = 0; i < seg->area_count; ++i) {
 		char buf[32];
-		lv_info(lv->vg->cmd, seg_lv(seg, i), &info, 0, 0);
+		lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0);
 		log_debug("Found mirror leg at %d:%d", info.major, info.minor);
 		sprintf(buf, "%d:%d", info.major, info.minor);
 		for (j = 0; j < num_devs; ++j) {
--- LVM2/lib/report/report.c	2010/07/09 15:34:46	1.123
+++ LVM2/lib/report/report.c	2010/08/17 16:25:35	1.124
@@ -245,7 +245,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 
-	if (lv_info(lv->vg->cmd, lv, &info, 0, 0) && info.exists)
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.major);
 
 	return dm_report_field_int32(rh, field, &_minusone32);
@@ -258,7 +258,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 
-	if (lv_info(lv->vg->cmd, lv, &info, 0, 0) && info.exists)
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
 		return dm_report_field_int(rh, field, &info.minor);
 
 	return dm_report_field_int32(rh, field, &_minusone32);
@@ -351,7 +351,7 @@
 	else
 		repstr[3] = '-';
 
-	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) && info.exists) {
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
 		if (info.suspended)
 			repstr[4] = 's';	/* Suspended */
 		else if (info.live_table)
@@ -683,7 +683,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 
-	if (!lv_info(lv->vg->cmd, lv, &info, 0, 1) || !info.exists)
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 1) || !info.exists)
 		return dm_report_field_int32(rh, field, &_minusone32);
 
 	return _size32_disp(rh, mem, field, &info.read_ahead, private);
@@ -1085,7 +1085,7 @@
 	}
 
 	if ((!lv_is_cow(lv) && !lv_is_merging_origin(lv)) ||
-	    !lv_info(lv->vg->cmd, lv, &info, 0, 0) || !info.exists) {
+	    !lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) || !info.exists) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;
--- LVM2/liblvm/lvm_lv.c	2010/07/09 16:57:34	1.24
+++ LVM2/liblvm/lvm_lv.c	2010/08/17 16:25:35	1.25
@@ -57,7 +57,7 @@
 uint64_t lvm_lv_is_active(const lv_t lv)
 {
 	struct lvinfo info;
-	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
 	    info.exists && info.live_table)
 		return 1;
 	return 0;
@@ -66,7 +66,7 @@
 uint64_t lvm_lv_is_suspended(const lv_t lv)
 {
 	struct lvinfo info;
-	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) &&
 	    info.exists && info.suspended)
 		return 1;
 	return 0;
--- LVM2/tools/lvchange.c	2010/08/16 22:54:37	1.123
+++ LVM2/tools/lvchange.c	2010/08/17 16:25:35	1.124
@@ -37,7 +37,7 @@
 	}
 
 	if ((lv->status & MIRRORED) && (vg_is_clustered(lv->vg)) &&
-	    lv_info(cmd, lv, &info, 0, 0) && info.exists) {
+	    lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 		log_error("Cannot change permissions of mirror \"%s\" "
 			  "while active.", lv->name);
 		return 0;
@@ -86,7 +86,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 0, 0) || !info.exists) {
+	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
 		log_error("Logical volume, %s, is not active", lv->name);
 		return 0;
 	}
@@ -96,7 +96,7 @@
 		return 1;
 
 	if ((dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) &&
-	    !monitor_dev_for_events(cmd, lv, dmeventd_monitor_mode()))
+	    !monitor_dev_for_events(cmd, lv, 0, dmeventd_monitor_mode()))
 		return_0;
 
 	return 1;
@@ -107,7 +107,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 0, 0) || !info.exists) {
+	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
 		log_error("Logical volume, %s, is not active", lv->name);
 		return 0;
 	}
@@ -189,7 +189,7 @@
 		return 0;
 	}
 
-	if (lv_info(cmd, lv, &info, 1, 0)) {
+	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (info.open_count) {
 			log_error("Can't resync open logical volume \"%s\"",
 				  lv->name);
@@ -446,7 +446,7 @@
 			log_error("Major number must be specified with -My");
 			return 0;
 		}
-		if (lv_info(cmd, lv, &info, 0, 0) && info.exists)
+		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists)
 			active = 1;
 		if (active && !arg_count(cmd, force_ARG) &&
 		    yes_no_prompt("Logical volume %s will be "
--- LVM2/tools/lvconvert.c	2010/08/06 15:38:32	1.145
+++ LVM2/tools/lvconvert.c	2010/08/17 16:25:35	1.146
@@ -1465,13 +1465,13 @@
 	 * constructor and DM should prevent appropriate devices from
 	 * being open.
 	 */
-	if (lv_info(cmd, origin, &info, 1, 0)) {
+	if (lv_info(cmd, origin, 0, &info, 1, 0)) {
 		if (info.open_count) {
 			log_error("Can't merge over open origin volume");
 			merge_on_activate = 1;
 		}
 	}
-	if (lv_info(cmd, lv, &info, 1, 0)) {
+	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
 		if (info.open_count) {
 			log_print("Can't merge when snapshot is open");
 			merge_on_activate = 1;
@@ -1633,7 +1633,7 @@
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, &info, 1, 0) || !info.exists) {
+	if (!lv_info(cmd, lv, 0, &info, 1, 0) || !info.exists) {
 		log_print("Conversion starts after activation.");
 		return ECMD_PROCESSED;
 	}
--- LVM2/tools/lvresize.c	2010/04/29 01:38:14	1.122
+++ LVM2/tools/lvresize.c	2010/08/17 16:25:35	1.123
@@ -90,7 +90,7 @@
 
 	memset(&info, 0, sizeof(info));
 
-	if (!lv_info(cmd, lv, &info, 1, 0) && driver_version(NULL, 0)) {
+	if (!lv_info(cmd, lv, 0, &info, 1, 0) && driver_version(NULL, 0)) {
 		log_error("lv_info failed: aborting");
 		return 0;
 	}
@@ -572,7 +572,7 @@
 
 		memset(&info, 0, sizeof(info));
 
-		if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
+		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 			log_error("Snapshot origin volumes can be resized "
 				  "only while inactive: try lvchange -an");
 			return ECMD_FAILED;
--- LVM2/tools/lvscan.c	2010/07/09 15:34:48	1.41
+++ LVM2/tools/lvscan.c	2010/08/17 16:25:35	1.42
@@ -31,7 +31,7 @@
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	inkernel = lv_info(cmd, lv, &info, 1, 0) && info.exists;
+	inkernel = lv_info(cmd, lv, 0, &info, 1, 0) && info.exists;
 	if (lv_is_origin(lv)) {
 		dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs,
 				       origin_list) {
--- LVM2/tools/vgchange.c	2010/08/17 01:16:41	1.112
+++ LVM2/tools/vgchange.c	2010/08/17 16:25:35	1.113
@@ -30,7 +30,7 @@
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
-		if (!lv_info(cmd, lv, &info, 0, 0))
+		if (!lv_info(cmd, lv, 0, &info, 0, 0))
 			lv_active = 0;
 		else
 			lv_active = info.exists;
@@ -41,7 +41,7 @@
 		if ((lv->status & PVMOVE) || !lv_active)
 			continue;
 
-		if (!monitor_dev_for_events(cmd, lv, reg)) {
+		if (!monitor_dev_for_events(cmd, lv, 0, reg)) {
 			r = ECMD_FAILED;
 			continue;
 		} else
@@ -63,7 +63,7 @@
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 
-		if (!lv_info(cmd, lv, &info, 0, 0))
+		if (!lv_info(cmd, lv, 0, &info, 0, 0))
 			lv_active = 0;
 		else
 			lv_active = info.exists;
--- LVM2/tools/vgconvert.c	2010/07/09 15:34:48	1.43
+++ LVM2/tools/vgconvert.c	2010/08/17 16:25:35	1.44
@@ -98,7 +98,7 @@
 				continue;
 			if (lvnum_from_lvid(&lv->lvid) < MAX_RESTRICTED_LVS)
 				continue;
-			if (lv_info(cmd, lv, &info, 0, 0) && info.exists) {
+			if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
 				log_error("Logical volume %s must be "
 					  "deactivated before conversion.",
 					   lv->name);
--- LVM2/tools/vgreduce.c	2010/07/09 15:34:48	1.103
+++ LVM2/tools/vgreduce.c	2010/08/17 16:25:35	1.104
@@ -108,7 +108,7 @@
 	 * the mirrored LV also should be cleaned up.
 	 * Clean-up is currently done by caller (_make_vg_consistent()).
 	 */
-	if ((lv_info(cmd, lv, &info, 0, 0) && info.exists) ||
+	if ((lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) ||
 	    find_mirror_seg(first_seg(lv))) {
 		if (!replace_lv_with_error_segment(lv))
 			return_0;


