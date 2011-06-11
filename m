From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jun 2011 00:03:10 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM daemons/clvmd/ ...
Message-ID: <20110611000310.10906.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-11 00:03:08

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	daemons/clvmd  : lvm-functions.c 
	lib/activate   : activate.c dev_manager.c dev_manager.h 
	lib/locking    : locking.c 
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	lib/mm         : memlock.c memlock.h 
	libdm          : libdm-deptree.c 
	tools          : pvmove.c vgchange.c 

Log message:
	Major pvmove fix to issue ioctls in the correct order when multiple LVs
	are affected by the move.  (Currently it's possible for I/O to become
	trapped between suspended devices amongst other problems.
	
	The current fix was selected so as to minimise the testing surface.  I
	hope eventually to replace it with a cleaner one that extends the
	deptree code.
	
	Some lvconvert scenarios still suffer from related problems.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2010&r2=1.2011
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.469&r2=1.470
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.196&r2=1.197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.260&r2=1.261
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.192&r2=1.193
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/WHATS_NEW	2011/06/09 19:38:56	1.2010
+++ LVM2/WHATS_NEW	2011/06/11 00:03:06	1.2011
@@ -1,5 +1,8 @@
 Version 2.02.86 -  
 =================================
+  Fix ignored background polling default in vgchange -ay.
+  Fix pvmove activation sequences to avoid trapped I/O with multiple LVs.
+  Annotate critical section debug messages.
   Fix reduction of mirrors with striped segments to always align to stripe size.
   Validate mirror segments size.
   Fix extent rounding for striped volumes (never reduce more than requested).
--- LVM2/WHATS_NEW_DM	2011/06/09 15:07:40	1.469
+++ LVM2/WHATS_NEW_DM	2011/06/11 00:03:06	1.470
@@ -1,6 +1,7 @@
 Version 1.02.65 - 
 ==================================
-  Accept new kernel version 3 formats in initialisation.
+  Delay resuming new preloaded mirror devices with core logs in deptree code.
+  Accept new kernel version 3 uname formats in initialisation.
 
 Version 1.02.64 - 29th April 2011
 ==================================
--- LVM2/daemons/clvmd/lvm-functions.c	2011/06/03 09:05:30	1.118
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/06/11 00:03:06	1.119
@@ -384,9 +384,9 @@
 		goto error;
 
 	if (lvi.suspended) {
-		critical_section_inc(cmd);
+		critical_section_inc(cmd, "resuming");
 		if (!lv_resume(cmd, resource, 0)) {
-			critical_section_dec(cmd);
+			critical_section_dec(cmd, "resumed");
 			goto error;
 		}
 	}
--- LVM2/lib/activate/activate.c	2011/02/18 14:47:29	1.196
+++ LVM2/lib/activate/activate.c	2011/06/11 00:03:07	1.197
@@ -534,7 +534,7 @@
 	if (!activation())
 		return 0;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
 	if (!(r = dev_manager_transient(dm, lv)))
@@ -556,7 +556,7 @@
 	if (!activation())
 		return 0;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
 	if (!(r = dev_manager_snapshot_percent(dm, lv, percent)))
@@ -591,7 +591,7 @@
 	if (!info.exists)
 		return 0;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
 	if (!(r = dev_manager_mirror_percent(dm, lv, wait, percent, event_nr)))
@@ -631,7 +631,7 @@
 	int r;
 	struct dev_manager *dm;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
 		return_0;
 
 	if (!(r = dev_manager_activate(dm, lv, origin_only)))
@@ -646,7 +646,7 @@
 	int r;
 	struct dev_manager *dm;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
 		return_0;
 
 	if (!(r = dev_manager_preload(dm, lv, origin_only, flush_required)))
@@ -661,7 +661,7 @@
 	int r;
 	struct dev_manager *dm;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
 	if (!(r = dev_manager_deactivate(dm, lv)))
@@ -676,7 +676,11 @@
 	int r;
 	struct dev_manager *dm;
 
-	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name)))
+	/*
+	 * When we are asked to manipulate (normally suspend/resume) the PVMOVE
+	 * device directly, we don't want to touch the devices that use it.
+	 */
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
 		return_0;
 
 	if (!(r = dev_manager_suspend(dm, lv, origin_only, lockfs, flush_required)))
@@ -1080,7 +1084,9 @@
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		       unsigned origin_only, int error_if_not_suspended)
 {
-	struct logical_volume *lv = NULL, *lv_pre = NULL;
+	struct logical_volume *lv = NULL, *lv_pre = NULL, *pvmove_lv = NULL;
+	struct lv_list *lvl_pre;
+	struct seg_list *sl;
 	struct lvinfo info;
 	int r = 0, lockfs = 0, flush_required = 0;
 
@@ -1111,7 +1117,7 @@
 		if (!error_if_not_suspended) {
 			r = 1;
 			if (info.suspended)
-				critical_section_inc(cmd);
+				critical_section_inc(cmd, "already suspended");
 		}
 		goto out;
 	}
@@ -1121,27 +1127,76 @@
 
 	lv_calculate_readahead(lv, NULL);
 
-	/* If VG was precommitted, preload devices for the LV */
+	/*
+	 * If VG was precommitted, preload devices for the LV.
+	 * If the PVMOVE LV is being removed, it's only present in the old
+	 * metadata and not the new, so we must explicitly add the new
+	 * tables for all the changed LVs here, as the relationships
+	 * are not found by walking the new metadata.
+	 */
 	if ((lv_pre->vg->status & PRECOMMITTED)) {
-		if (!_lv_preload(lv_pre, origin_only, &flush_required)) {
+		if (!(lv_pre->status & LOCKED) &&
+		    (lv->status & LOCKED) &&
+		    (pvmove_lv = find_pvmove_lv_in_lv(lv))) {
+			/* Preload all the LVs above the PVMOVE LV */
+			dm_list_iterate_items(sl, &pvmove_lv->segs_using_this_lv) {
+				if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, sl->seg->lv->name))) {
+					/* FIXME Internal error? */
+					log_error("LV %s missing from preload metadata", sl->seg->lv->name);
+					goto out;
+				}
+				if (!_lv_preload(lvl_pre->lv, origin_only, &flush_required))
+					goto_out;
+			}
+			/* Now preload the PVMOVE LV itself */
+			if (!(lvl_pre = find_lv_in_vg(lv_pre->vg, pvmove_lv->name))) {
+				/* FIXME Internal error? */
+				log_error("LV %s missing from preload metadata", pvmove_lv->name);
+				goto out;
+			}
+			if (!_lv_preload(lvl_pre->lv, origin_only, &flush_required))
+				goto_out;
+		} else if (!_lv_preload(lv_pre, origin_only, &flush_required))
 			/* FIXME Revert preloading */
 			goto_out;
-		}
 	}
 
 	if (!monitor_dev_for_events(cmd, lv, origin_only, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
-	critical_section_inc(cmd);
+	critical_section_inc(cmd, "suspending");
+	if (pvmove_lv)
+		critical_section_inc(cmd, "suspending pvmove LV");
 
 	if (!origin_only &&
 	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
-	if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
-		critical_section_dec(cmd);
-		goto out;
+	/*
+	 * Suspending an LV directly above a PVMOVE LV also
+ 	 * suspends other LVs using that same PVMOVE LV.
+	 * FIXME Remove this and delay the 'clear node' until
+ 	 * after the code knows whether there's a different
+ 	 * inactive table to load or not instead so lv_suspend
+ 	 * can be called separately for each LV safely.
+ 	 */
+	if ((lv_pre->vg->status & PRECOMMITTED) &&
+	    (lv_pre->status & LOCKED) && find_pvmove_lv_in_lv(lv_pre)) {
+		if (!_lv_suspend_lv(lv_pre, origin_only, lockfs, flush_required)) {
+			critical_section_dec(cmd, "failed precommitted suspend");
+			if (pvmove_lv)
+				critical_section_dec(cmd, "failed precommitted suspend (pvmove)");
+			goto_out;
+		}
+	} else {
+		/* Normal suspend */
+		if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
+			critical_section_dec(cmd, "failed suspend");
+			if (pvmove_lv)
+				critical_section_dec(cmd, "failed suspend (pvmove)");
+			goto_out;
+		}
 	}
 
 	r = 1;
@@ -1210,6 +1265,8 @@
 		if (error_if_not_active)
 			goto_out;
 		r = 1;
+		if (!info.suspended)
+			critical_section_dec(cmd, "already resumed");
 		goto out;
 	}
 
@@ -1224,7 +1281,7 @@
 	if (!_lv_activate_lv(lv, origin_only))
 		goto_out;
 
-	critical_section_dec(cmd);
+	critical_section_dec(cmd, "resumed");
 
 	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
 		stack;
@@ -1316,9 +1373,9 @@
 	if (!monitor_dev_for_events(cmd, lv, 0, 0))
 		stack;
 
-	critical_section_inc(cmd);
+	critical_section_inc(cmd, "deactivating");
 	r = _lv_deactivate(lv);
-	critical_section_dec(cmd);
+	critical_section_dec(cmd, "deactivated");
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0) || info.exists)
 		r = 0;
@@ -1413,10 +1470,10 @@
 	if (exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
-	critical_section_inc(cmd);
+	critical_section_inc(cmd, "activating");
 	if (!(r = _lv_activate_lv(lv, 0)))
 		stack;
-	critical_section_dec(cmd);
+	critical_section_dec(cmd, "activated");
 
 	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
 		stack;
--- LVM2/lib/activate/dev_manager.c	2011/03/29 20:30:08	1.216
+++ LVM2/lib/activate/dev_manager.c	2011/06/11 00:03:07	1.217
@@ -49,6 +49,7 @@
 	void *target_state;
 	uint32_t pvmove_mirror_count;
 	int flush_required;
+	unsigned track_pvmove_deps;
 
 	char *vg_name;
 };
@@ -640,7 +641,8 @@
  * dev_manager implementation.
  */
 struct dev_manager *dev_manager_create(struct cmd_context *cmd,
-				       const char *vg_name)
+				       const char *vg_name,
+				       unsigned track_pvmove_deps)
 {
 	struct dm_pool *mem;
 	struct dev_manager *dm;
@@ -657,6 +659,12 @@
 	if (!(dm->vg_name = dm_pool_strdup(dm->mem, vg_name)))
 		goto_bad;
 
+	/*
+	 * When we manipulate (normally suspend/resume) the PVMOVE
+	 * device directly, there's no need to touch the LVs above.
+	 */
+	dm->track_pvmove_deps = track_pvmove_deps;
+
 	dm->target_state = NULL;
 
 	dm_udev_set_sync_support(cmd->current_settings.udev_sync);
@@ -1039,6 +1047,8 @@
  */
 static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv, unsigned origin_only)
 {
+	struct seg_list *sl;
+
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
 
@@ -1053,6 +1063,12 @@
 	    !_add_dev_to_dtree(dm, dtree, first_seg(lv)->log_lv, NULL))
 		return_0;
 
+	/* Add any LVs referencing a PVMOVE LV unless told not to. */
+	if (dm->track_pvmove_deps && lv->status & PVMOVE)
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+			if (!_add_lv_to_dtree(dm, dtree, sl->seg->lv, origin_only))
+				return_0;
+
 	/* Adding LV head of replicator adds all other related devs */
 	if (lv_is_replicator_dev(lv) &&
 	    !_add_partial_replicator_to_dtree(dm, dtree, lv))
@@ -1436,10 +1452,11 @@
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				  struct logical_volume *lv, const char *layer)
+				struct logical_volume *lv, const char *layer)
 {
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
+	struct seg_list *sl;
 	struct dm_tree_node *dnode;
 	const struct dm_info *dinfo;
 	char *name, *dlid;
@@ -1492,6 +1509,9 @@
 	 * existing inactive table left behind.
 	 * Major/minor settings only apply to the visible layer.
 	 */
+	/* FIXME Move the clear from here until later, so we can leave
+	 * identical inactive tables untouched. (For pvmove.)
+	 */
 	if (!(dnode = dm_tree_add_new_dev_with_udev_flags(dtree, name, dlid,
 					     layer ? UINT32_C(0) : (uint32_t) lv->major,
 					     layer ? UINT32_C(0) : (uint32_t) lv->minor,
@@ -1528,6 +1548,12 @@
 
 	dm_tree_node_set_read_ahead(dnode, read_ahead, read_ahead_flags);
 
+	/* Add any LVs referencing a PVMOVE LV unless told not to */
+	if (dm->track_pvmove_deps && (lv->status & PVMOVE))
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, NULL))
+				return_0;
+
 	return 1;
 }
 
@@ -1744,10 +1770,6 @@
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
 			unsigned origin_only, int *flush_required)
 {
-	/* FIXME Update the pvmove implementation! */
-	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
-		return 1;
-
 	if (!_tree_action(dm, lv, origin_only, PRELOAD))
 		return 0;
 
--- LVM2/lib/activate/dev_manager.h	2010/11/30 22:28:06	1.36
+++ LVM2/lib/activate/dev_manager.h	2011/06/11 00:03:07	1.37
@@ -29,7 +29,8 @@
  * Constructor and destructor.
  */
 struct dev_manager *dev_manager_create(struct cmd_context *cmd,
-				       const char *vg_name);
+				       const char *vg_name,
+				       unsigned track_pvmove_deps);
 void dev_manager_destroy(struct dev_manager *dm);
 void dev_manager_release(void);
 void dev_manager_exit(void);
--- LVM2/lib/locking/locking.c	2011/04/28 20:29:59	1.94
+++ LVM2/lib/locking/locking.c	2011/06/11 00:03:07	1.95
@@ -167,7 +167,7 @@
 		return;
 
 	if (lv_op == LV_SUSPEND)
-		critical_section_inc(cmd);
+		critical_section_inc(cmd, "locking for suspend");
 }
 
 static void _unlock_memory(struct cmd_context *cmd, lv_operation_t lv_op)
@@ -176,7 +176,7 @@
 		return;
 
 	if (lv_op == LV_RESUME)
-		critical_section_dec(cmd);
+		critical_section_dec(cmd, "unlocking on resume");
 }
 
 void reset_locking(void)
--- LVM2/lib/metadata/lv_manip.c	2011/06/06 12:08:42	1.260
+++ LVM2/lib/metadata/lv_manip.c	2011/06/11 00:03:07	1.261
@@ -494,15 +494,19 @@
 {
 	uint32_t len = lv->le_count;
 
-	if (!lv_empty(lv))
+	if (len && !lv_empty(lv))
 		return_0;
 
+	/* Minimum size required for a table. */
+	if (!len)
+		len = 1;
+
 	/*
 	 * Since we are replacing the whatever-was-there with
 	 * an error segment, we should also clear any flags
 	 * that suggest it is anything other than "error".
 	 */
-	lv->status &= ~MIRRORED;
+	lv->status &= ~(MIRRORED|PVMOVE);
 
 	/* FIXME: Should we bug if we find a log_lv attached? */
 
--- LVM2/lib/metadata/metadata-exported.h	2011/06/01 19:21:04	1.192
+++ LVM2/lib/metadata/metadata-exported.h	2011/06/11 00:03:07	1.193
@@ -753,6 +753,7 @@
 						  const char *name,
 						  const char *uuid,
 						  uint32_t lv_type);
+struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv(struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(struct logical_volume *lv_mirr);
 percent_t copy_percent(const struct logical_volume *lv_mirr);
--- LVM2/lib/metadata/mirror.c	2011/04/28 20:30:00	1.151
+++ LVM2/lib/metadata/mirror.c	2011/06/11 00:03:07	1.152
@@ -1445,7 +1445,10 @@
 	return NULL;
 }
 
-const char *get_pvmove_pvname_from_lv(struct logical_volume *lv)
+/*
+ * Find first pvmove LV referenced by a segment of an LV.
+ */
+struct logical_volume *find_pvmove_lv_in_lv(struct logical_volume *lv)
 {
 	struct lv_segment *seg;
 	uint32_t s;
@@ -1454,13 +1457,26 @@
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			return get_pvmove_pvname_from_lv_mirr(seg_lv(seg, s));
+			if (seg_lv(seg, s)->status & PVMOVE)
+				return seg_lv(seg, s);
 		}
 	}
 
 	return NULL;
 }
 
+const char *get_pvmove_pvname_from_lv(struct logical_volume *lv)
+{
+	struct logical_volume *pvmove_lv;
+
+	pvmove_lv = find_pvmove_lv_in_lv(lv);
+
+	if (pvmove_lv)
+		return get_pvmove_pvname_from_lv_mirr(pvmove_lv);
+	else
+		return NULL;
+}
+
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev,
 				      uint32_t lv_type)
--- LVM2/lib/mm/memlock.c	2011/06/01 19:26:38	1.42
+++ LVM2/lib/mm/memlock.c	2011/06/11 00:03:07	1.43
@@ -395,19 +395,21 @@
 	}
 }
 
-void critical_section_inc(struct cmd_context *cmd)
+void critical_section_inc(struct cmd_context *cmd, const char *reason)
 {
 	++_critical_section_count;
-	log_debug("critical_section_inc to %d", _critical_section_count);
+	log_debug("critical_section_inc to %d (%s).", _critical_section_count,
+		  reason);
 	_lock_mem_if_needed(cmd);
 }
 
-void critical_section_dec(struct cmd_context *cmd)
+void critical_section_dec(struct cmd_context *cmd, const char *reason)
 {
 	if (!_critical_section_count)
 		log_error(INTERNAL_ERROR "_critical_section has dropped below 0.");
 	--_critical_section_count;
-	log_debug("critical_section_dec to %d", _critical_section_count);
+	log_debug("critical_section_dec to %d (%s).", _critical_section_count,
+		  reason);
 }
 
 int critical_section(void)
--- LVM2/lib/mm/memlock.h	2011/04/28 20:30:00	1.8
+++ LVM2/lib/mm/memlock.h	2011/06/11 00:03:07	1.9
@@ -31,8 +31,8 @@
  * memlock_reset() is necessary to clear the state after forking (polldaemon).
  */
 
-void critical_section_inc(struct cmd_context *cmd);
-void critical_section_dec(struct cmd_context *cmd);
+void critical_section_inc(struct cmd_context *cmd, const char *reason);
+void critical_section_dec(struct cmd_context *cmd, const char *reason);
 int critical_section(void);
 void memlock_inc_daemon(struct cmd_context *cmd);
 void memlock_dec_daemon(struct cmd_context *cmd);
--- LVM2/libdm/libdm-deptree.c	2011/06/09 15:52:59	1.93
+++ LVM2/libdm/libdm-deptree.c	2011/06/11 00:03:07	1.94
@@ -149,7 +149,16 @@
 	 * and processing of dm tree). This will also flush all stacked dev
 	 * node operations, synchronizing with udev.
 	 */
-	int immediate_dev_node;
+	unsigned immediate_dev_node;
+
+	/*
+	 * If the device size changed from zero and this is set,
+	 * don't resume the device immediately, even if the device
+	 * has parents.  This works provided the parents do not
+	 * validate the device size and is required by pvmove to
+	 * avoid starting the mirror resync operation too early.
+	 */
+	unsigned delay_resume_if_new;
 };
 
 /* Two of these used to join two nodes with uses and used_by. */
@@ -1795,7 +1804,7 @@
 	int r = 0;
 	struct dm_task *dmt;
 	struct load_segment *seg;
-	uint64_t seg_start = 0;
+	uint64_t seg_start = 0, existing_table_size;
 
 	log_verbose("Loading %s table (%" PRIu32 ":%" PRIu32 ")", dnode->name,
 		    dnode->info.major, dnode->info.minor);
@@ -1833,12 +1842,20 @@
 			log_verbose("Suppressed %s identical table reload.",
 				    dnode->name);
 
+		existing_table_size = dm_task_get_existing_table_size(dmt);
 		if ((dnode->props.size_changed =
-		     (dm_task_get_existing_table_size(dmt) == seg_start) ? 0 : 1))
+		     (existing_table_size == seg_start) ? 0 : 1)) {
 			log_debug("Table size changed from %" PRIu64 " to %"
-				  PRIu64 " for %s",
-				  dm_task_get_existing_table_size(dmt),
+				  PRIu64 " for %s", existing_table_size,
 				  seg_start, dnode->name);
+			/*
+			 * Kernel usually skips size validation on zero-length devices
+			 * now so no need to preload them.
+			 */
+			/* FIXME In which kernel version did this begin? */
+			if (!existing_table_size && dnode->props.delay_resume_if_new)
+				dnode->props.size_changed = 0;
+		}
 	}
 
 	dnode->props.segment_count = 0;
@@ -2181,7 +2198,10 @@
 			log_error("log uuid pool_strdup failed");
 			return 0;
 		}
-		if (!(flags & DM_CORELOG)) {
+		if ((flags & DM_CORELOG))
+			/* For pvmove: immediate resume (for size validation) isn't needed. */
+			node->props.delay_resume_if_new = 1;
+		else {
 			if (!(log_node = dm_tree_find_node_by_uuid(node->dtree, log_uuid))) {
 				log_error("Couldn't find mirror log uuid %s.", log_uuid);
 				return 0;
--- LVM2/tools/pvmove.c	2011/03/29 20:19:04	1.83
+++ LVM2/tools/pvmove.c	2011/06/11 00:03:07	1.84
@@ -305,6 +305,51 @@
 	return 1;
 }
 
+static int _suspend_lvs(struct cmd_context *cmd, unsigned first_time,
+			struct logical_volume *lv_mirr,
+			struct dm_list *lvs_changed)
+{
+	/*
+	 * Suspend lvs_changed the first time.
+	 * Suspend mirrors on subsequent calls.
+	 */
+	if (first_time) {
+		if (!suspend_lvs(cmd, lvs_changed))
+			return_0;
+	} else if (!suspend_lv(cmd, lv_mirr))
+		return_0;
+
+	return 1;
+}
+
+static int _resume_lvs(struct cmd_context *cmd, unsigned first_time,
+		       struct logical_volume *lv_mirr,
+		       struct dm_list *lvs_changed)
+{
+	/*
+	 * Suspend lvs_changed the first time.
+	 * Suspend mirrors on subsequent calls.
+	 */
+
+	if (first_time) {
+		if (!resume_lvs(cmd, lvs_changed)) {
+			log_error("Unable to resume logical volumes");
+			return 0;
+		}
+	} else if (!resume_lv(cmd, lv_mirr)) {
+		log_error("Unable to reactivate logical volume \"%s\"",
+			  lv_mirr->name);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Called to set up initial pvmove LV and to advance the mirror
+ * to successive sections of it.
+ * (Not called after the last section completes.)
+ */
 static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			    struct logical_volume *lv_mirr,
 			    struct dm_list *lvs_changed, unsigned flags)
@@ -319,30 +364,14 @@
 		return 0;
 	}
 
-	/* Suspend lvs_changed */
-	if (!suspend_lvs(cmd, lvs_changed)) {
+	if (!_suspend_lvs(cmd, first_time, lv_mirr, lvs_changed)) {
 		vg_revert(vg);
 		goto_out;
 	}
 
-	/* Suspend mirrors on subsequent calls */
-	if (!first_time) {
-		if (!suspend_lv(cmd, lv_mirr)) {
-			if (!resume_lvs(cmd, lvs_changed))
-				stack;
-			vg_revert(vg);
-			goto_out;
-		}
-	}
-
 	/* Commit on-disk metadata */
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Volume group metadata update failed.");
-		if (!first_time)
-			if (!resume_lv(cmd, lv_mirr))
-				stack;
-		if (!resume_lvs(cmd, lvs_changed))
-			stack;
 		vg_revert(vg);
 		goto out;
 	}
@@ -358,9 +387,6 @@
 			}
 
 			/*
-			 * FIXME: review ordering of operations above,
-			 * temporary mirror should be preloaded in suspend.
-			 * Also banned operation here when suspended.
 			 * Nothing changed yet, try to revert pvmove.
 			 */
 			log_error("Temporary pvmove mirror activation failed.");
@@ -374,29 +400,16 @@
 			    !vg_write(vg) || !vg_commit(vg))
 				log_error("ABORTING: Restoring original configuration "
 					  "before pvmove failed. Run pvmove --abort.");
-
-			/* Unsuspend LVs */
-			if(!resume_lvs(cmd, lvs_changed))
-				stack;
-
-			goto out;
+			goto_out;
 		}
-	} else if (!resume_lv(cmd, lv_mirr)) {
-		log_error("Unable to reactivate logical volume \"%s\"",
-			  lv_mirr->name);
-		if (!resume_lvs(cmd, lvs_changed))
-			stack;
-		goto out;
-	}
-
-	/* Unsuspend LVs */
-	if (!resume_lvs(cmd, lvs_changed)) {
-		log_error("Unable to resume logical volumes");
-		goto out;
 	}
 
 	r = 1;
+
 out:
+	if (!_resume_lvs(cmd, first_time, lv_mirr, lvs_changed))
+		r = 0;
+
 	backup(vg);
 	return r;
 }
@@ -524,7 +537,8 @@
 	int r = 1;
 
 	if (!dm_list_empty(lvs_changed) &&
-	    !_detach_pvmove_mirror(cmd, lv_mirr)) {
+	    (!_detach_pvmove_mirror(cmd, lv_mirr) ||
+	    !replace_lv_with_error_segment(lv_mirr))) {
 		log_error("ABORTING: Removal of temporary mirror failed");
 		return 0;
 	}
@@ -536,18 +550,12 @@
 		return 0;
 	}
 
-	/* Suspend LVs changed */
+	/* Suspend LVs changed (implicitly suspends lv_mirr) */
 	if (!suspend_lvs(cmd, lvs_changed)) {
 		log_error("Locking LVs to remove temporary mirror failed");
 		r = 0;
 	}
 
-	/* Suspend mirror LV to flush pending I/O */
-	if (!suspend_lv(cmd, lv_mirr)) {
-		log_error("Suspension of temporary mirror LV failed");
-		r = 0;
-	}
-
 	/* Store metadata without dependencies on mirror segments */
 	if (!vg_commit(vg)) {
 		log_error("ABORTING: Failed to write new data locations "
--- LVM2/tools/vgchange.c	2011/03/02 20:00:09	1.120
+++ LVM2/tools/vgchange.c	2011/06/11 00:03:08	1.121
@@ -523,7 +523,7 @@
 	}
 
 	if (!arg_count(cmd, refresh_ARG) &&
-	    arg_count(cmd, poll_ARG))
+	    background_polling())
 		if (!_vgchange_background_polling(cmd, vg))
 			return ECMD_FAILED;
 


