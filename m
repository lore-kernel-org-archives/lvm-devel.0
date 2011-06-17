From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2011 14:14:23 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20110617141423.32545.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-17 14:14:21

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	lib/error      : errseg.c 
	lib/metadata   : segtype.h 
	lib/mirror     : mirrored.c 
	lib/replicator : replicator.c 
	lib/snapshot   : snapshot.c 
	lib/striped    : striped.c 
	lib/unknown    : unknown.c 
	lib/zero       : zero.c 

Log message:
	Add lv_activate_opts structure
	
	To avoid modification of 'read-only' volume group structure
	add a new structure to pass local data around the code for LV
	activation.
	
	As origin_only is one such flag - replace this parameter with new
	struct lv_activate_opts.
	
	More parameters might eventually become part of lv_activate_opts.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2016&r2=1.2017
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.198&r2=1.199
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.217&r2=1.218
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/error/errseg.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/unknown/unknown.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/zero/zero.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/WHATS_NEW	2011/06/15 17:48:35	1.2016
+++ LVM2/WHATS_NEW	2011/06/17 14:14:19	1.2017
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Add lv_activate_opts structure for activation (replacing activation flags).
   Fix a problem with inconsistent pre-commit metadata on MISSING_PV devices.
   Add proper udev library context initialization and finalization to liblvm.
   Fix last snapshot removal to avoid table reload while a device is suspended.
--- LVM2/lib/activate/activate.c	2011/06/13 22:28:04	1.198
+++ LVM2/lib/activate/activate.c	2011/06/17 14:14:19	1.199
@@ -243,7 +243,7 @@
 	return 1;
 }
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
-			   unsigned origin_only, int monitor)
+			   struct lv_activate_opts *laopts, int monitor)
 {
 	return 1;
 }
@@ -632,7 +632,7 @@
 	return info.open_count;
 }
 
-static int _lv_activate_lv(struct logical_volume *lv, unsigned origin_only)
+static int _lv_activate_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
 {
 	int r;
 	struct dev_manager *dm;
@@ -640,14 +640,15 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
 		return_0;
 
-	if (!(r = dev_manager_activate(dm, lv, origin_only)))
+	if (!(r = dev_manager_activate(dm, lv, laopts)))
 		stack;
 
 	dev_manager_destroy(dm);
 	return r;
 }
 
-static int _lv_preload(struct logical_volume *lv, unsigned origin_only, int *flush_required)
+static int _lv_preload(struct logical_volume *lv, struct lv_activate_opts *laopts,
+		       int *flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -655,7 +656,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
 		return_0;
 
-	if (!(r = dev_manager_preload(dm, lv, origin_only, flush_required)))
+	if (!(r = dev_manager_preload(dm, lv, laopts, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -677,7 +678,8 @@
 	return r;
 }
 
-static int _lv_suspend_lv(struct logical_volume *lv, unsigned origin_only, int lockfs, int flush_required)
+static int _lv_suspend_lv(struct logical_volume *lv, struct lv_activate_opts *laopts,
+			  int lockfs, int flush_required)
 {
 	int r;
 	struct dev_manager *dm;
@@ -689,7 +691,7 @@
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
 		return_0;
 
-	if (!(r = dev_manager_suspend(dm, lv, origin_only, lockfs, flush_required)))
+	if (!(r = dev_manager_suspend(dm, lv, laopts, lockfs, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
@@ -955,7 +957,7 @@
  * Returns 1 otherwise.
  */
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
-			   unsigned origin_only, int monitor)
+			   const struct lv_activate_opts *laopts, int monitor)
 {
 #ifdef DMEVENTD
 	int i, pending = 0, monitored;
@@ -965,6 +967,10 @@
 	struct lv_segment *log_seg;
 	int (*monitor_fn) (struct lv_segment *s, int e);
 	uint32_t s;
+	static const struct lv_activate_opts zlaopts = { 0 };
+
+	if (!laopts)
+		laopts = &zlaopts;
 
 	/* skip dmeventd code altogether */
 	if (dmeventd_monitor_mode() == DMEVENTD_MONITOR_IGNORE)
@@ -988,10 +994,10 @@
 	 * each of its respective snapshots.  The origin itself may
 	 * also need to be monitored if it is a mirror, for example.
 	 */
-	if (!origin_only && lv_is_origin(lv))
+	if (!laopts->origin_only && lv_is_origin(lv))
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!monitor_dev_for_events(cmd, dm_list_struct_base(snh,
-				    struct lv_segment, origin_list)->cow, 0, monitor))
+				    struct lv_segment, origin_list)->cow, NULL, monitor))
 				r = 0;
 
 	/*
@@ -1001,7 +1007,7 @@
 	if ((seg = first_seg(lv)) != NULL && seg->log_lv != NULL &&
 	    (log_seg = first_seg(seg->log_lv)) != NULL &&
 	    seg_is_mirrored(log_seg))
-		if (!monitor_dev_for_events(cmd, seg->log_lv, 0, monitor))
+		if (!monitor_dev_for_events(cmd, seg->log_lv, NULL, monitor))
 			r = 0;
 
 	dm_list_iterate(tmp, &lv->segments) {
@@ -1011,7 +1017,7 @@
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			if (!monitor_dev_for_events(cmd, seg_lv(seg, s), 0,
+			if (!monitor_dev_for_events(cmd, seg_lv(seg, s), NULL,
 						    monitor)) {
 				log_error("Failed to %smonitor %s",
 					  monitor ? "" : "un",
@@ -1092,7 +1098,7 @@
 }
 
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
-		       unsigned origin_only, int error_if_not_suspended)
+		       struct lv_activate_opts *laopts, int error_if_not_suspended)
 {
 	struct logical_volume *lv = NULL, *lv_pre = NULL, *pvmove_lv = NULL;
 	struct lv_list *lvl_pre;
@@ -1112,15 +1118,15 @@
 
 	/* Ignore origin_only unless LV is origin in both old and new metadata */
 	if (!lv_is_origin(lv) || !lv_is_origin(lv_pre))
-		origin_only = 0;
+		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Suspending %s%s.", lv->name, origin_only ? " origin without snapshots" : "");
+		_skip("Suspending %s%s.", lv->name, laopts->origin_only ? " origin without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
-	if (!lv_info(cmd, lv, origin_only, &info, 0, 0))
+	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || info.suspended) {
@@ -1155,7 +1161,7 @@
 					log_error("LV %s missing from preload metadata", sl->seg->lv->name);
 					goto out;
 				}
-				if (!_lv_preload(lvl_pre->lv, origin_only, &flush_required))
+				if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
 					goto_out;
 			}
 			/* Now preload the PVMOVE LV itself */
@@ -1164,14 +1170,14 @@
 				log_error("LV %s missing from preload metadata", pvmove_lv->name);
 				goto out;
 			}
-			if (!_lv_preload(lvl_pre->lv, origin_only, &flush_required))
+			if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
 				goto_out;
-		} else if (!_lv_preload(lv_pre, origin_only, &flush_required))
+		} else if (!_lv_preload(lv_pre, laopts, &flush_required))
 			/* FIXME Revert preloading */
 			goto_out;
 	}
 
-	if (!monitor_dev_for_events(cmd, lv, origin_only, 0))
+	if (!monitor_dev_for_events(cmd, lv, laopts, 0))
 		/* FIXME Consider aborting here */
 		stack;
 
@@ -1179,7 +1185,7 @@
 	if (pvmove_lv)
 		critical_section_inc(cmd, "suspending pvmove LV");
 
-	if (!origin_only &&
+	if (!laopts->origin_only &&
 	    (lv_is_origin(lv_pre) || lv_is_cow(lv_pre)))
 		lockfs = 1;
 
@@ -1193,7 +1199,7 @@
  	 */
 	if ((lv_pre->vg->status & PRECOMMITTED) &&
 	    (lv_pre->status & LOCKED) && find_pvmove_lv_in_lv(lv_pre)) {
-		if (!_lv_suspend_lv(lv_pre, origin_only, lockfs, flush_required)) {
+		if (!_lv_suspend_lv(lv_pre, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed precommitted suspend");
 			if (pvmove_lv)
 				critical_section_dec(cmd, "failed precommitted suspend (pvmove)");
@@ -1201,7 +1207,7 @@
 		}
 	} else {
 		/* Normal suspend */
-		if (!_lv_suspend_lv(lv, origin_only, lockfs, flush_required)) {
+		if (!_lv_suspend_lv(lv, laopts, lockfs, flush_required)) {
 			critical_section_dec(cmd, "failed suspend");
 			if (pvmove_lv)
 				critical_section_dec(cmd, "failed suspend (pvmove)");
@@ -1224,7 +1230,9 @@
 /* Returns success if the device is not active */
 int lv_suspend_if_active(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_suspend(cmd, lvid_s, origin_only, 0);
+	struct lv_activate_opts laopts = { .origin_only = origin_only };
+
+	return _lv_suspend(cmd, lvid_s, &laopts, 0);
 }
 
 /* No longer used */
@@ -1246,8 +1254,7 @@
   * @error_if_not_active
   */
 static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
-		      unsigned origin_only, unsigned exclusive,
-		      int error_if_not_active)
+		      struct lv_activate_opts *laopts, int error_if_not_active)
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
@@ -1260,19 +1267,19 @@
 		goto_out;
 
 	if (!lv_is_origin(lv))
-		origin_only = 0;
+		laopts->origin_only = 0;
 
 	if (test_mode()) {
-		_skip("Resuming %s%s.", lv->name, origin_only ? " without snapshots" : "");
+		_skip("Resuming %s%s.", lv->name, laopts->origin_only ? " without snapshots" : "");
 		r = 1;
 		goto out;
 	}
 
 	log_debug("Resuming LV %s/%s%s%s.", lv->vg->name, lv->name,
 		  error_if_not_active ? "" : " if active",
-		  origin_only ? " without snapshots" : "");
+		  laopts->origin_only ? " without snapshots" : "");
 
-	if (!lv_info(cmd, lv, origin_only, &info, 0, 0))
+	if (!lv_info(cmd, lv, laopts->origin_only, &info, 0, 0))
 		goto_out;
 
 	if (!info.exists || !info.suspended) {
@@ -1289,15 +1296,15 @@
 	 * non-clustered target should be used.  This only happens
 	 * if ACTIVATE_EXCL is set in lv->status.
 	 */
-	if (exclusive)
+	if (laopts->exclusive)
 		lv->status |= ACTIVATE_EXCL;
 
-	if (!_lv_activate_lv(lv, origin_only))
+	if (!_lv_activate_lv(lv, laopts))
 		goto_out;
 
 	critical_section_dec(cmd, "resumed");
 
-	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
+	if (!monitor_dev_for_events(cmd, lv, laopts, 1))
 		stack;
 
 	r = 1;
@@ -1312,12 +1319,24 @@
 int lv_resume_if_active(struct cmd_context *cmd, const char *lvid_s,
 			unsigned origin_only, unsigned exclusive)
 {
-	return _lv_resume(cmd, lvid_s, origin_only, exclusive, 0);
+	struct lv_activate_opts laopts = {
+		.origin_only = origin_only,
+		/*
+		 * When targets are activated exclusively in a cluster, the
+		 * non-clustered target should be used.  This only happens
+		 * if exclusive is set.
+		 */
+		.exclusive = exclusive
+	};
+
+	return _lv_resume(cmd, lvid_s, &laopts, 0);
 }
 
 int lv_resume(struct cmd_context *cmd, const char *lvid_s, unsigned origin_only)
 {
-	return _lv_resume(cmd, lvid_s, origin_only, 0, 1);
+	struct lv_activate_opts laopts = { .origin_only = origin_only, };
+
+	return _lv_resume(cmd, lvid_s, &laopts, 1);
 }
 
 static int _lv_has_open_snapshots(struct logical_volume *lv)
@@ -1386,7 +1405,7 @@
 
 	lv_calculate_readahead(lv, NULL);
 
-	if (!monitor_dev_for_events(cmd, lv, 0, 0))
+	if (!monitor_dev_for_events(cmd, lv, NULL, 0))
 		stack;
 
 	critical_section_inc(cmd, "deactivating");
@@ -1434,7 +1453,7 @@
 }
 
 static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
-			int exclusive, int filter)
+			struct lv_activate_opts *laopts, int filter)
 {
 	struct logical_volume *lv;
 	struct lvinfo info;
@@ -1470,7 +1489,8 @@
 		goto out;
 	}
 
-	log_debug("Activating %s/%s%s.", lv->vg->name, lv->name, exclusive ? " exclusively" : "");
+	log_debug("Activating %s/%s%s.", lv->vg->name, lv->name,
+		  laopts->exclusive ? " exclusively" : "");
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
@@ -1485,15 +1505,12 @@
 
 	lv_calculate_readahead(lv, NULL);
 
-	if (exclusive)
-		lv->status |= ACTIVATE_EXCL;
-
 	critical_section_inc(cmd, "activating");
-	if (!(r = _lv_activate_lv(lv, 0)))
+	if (!(r = _lv_activate_lv(lv, laopts)))
 		stack;
 	critical_section_dec(cmd, "activated");
 
-	if (r && !monitor_dev_for_events(cmd, lv, 0, 1))
+	if (r && !monitor_dev_for_events(cmd, lv, laopts, 1))
 		stack;
 
 out:
@@ -1508,7 +1525,9 @@
 /* Activate LV */
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive)
 {
-	if (!_lv_activate(cmd, lvid_s, exclusive, 0))
+	struct lv_activate_opts laopts = { .exclusive = exclusive };
+
+	if (!_lv_activate(cmd, lvid_s, &laopts, 0))
 		return_0;
 
 	return 1;
@@ -1517,7 +1536,9 @@
 /* Activate LV only if it passes filter */
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive)
 {
-	if (!_lv_activate(cmd, lvid_s, exclusive, 1))
+	struct lv_activate_opts laopts = { .exclusive = exclusive };
+
+	if (!_lv_activate(cmd, lvid_s, &laopts, 1))
 		return_0;
 
 	return 1;
--- LVM2/lib/activate/activate.h	2011/02/18 14:47:29	1.76
+++ LVM2/lib/activate/activate.h	2011/06/17 14:14:19	1.77
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -30,6 +30,12 @@
 	uint32_t read_ahead;
 };
 
+struct lv_activate_opts {
+	int exclusive;
+	int origin_only;
+	int no_merging;
+};
+
 /* target attribute flags */
 #define MIRROR_LOG_CLUSTERED	0x00000001U
 
@@ -102,7 +108,7 @@
 		       const char *layer, const char *target_type);
 
 int monitor_dev_for_events(struct cmd_context *cmd, struct logical_volume *lv,
-			   unsigned origin_only, int do_reg);
+			   const struct lv_activate_opts *laopts, int do_reg);
 
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
--- LVM2/lib/activate/dev_manager.c	2011/06/11 00:03:07	1.217
+++ LVM2/lib/activate/dev_manager.c	2011/06/17 14:14:19	1.218
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -1045,7 +1045,7 @@
 /*
  * Add LV and any known dependencies
  */
-static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv, unsigned origin_only)
+static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree, struct logical_volume *lv, int origin_only)
 {
 	struct seg_list *sl;
 
@@ -1077,7 +1077,7 @@
 	return 1;
 }
 
-static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only)
+static struct dm_tree *_create_partial_dtree(struct dev_manager *dm, struct logical_volume *lv, int origin_only)
 {
 	struct dm_tree *dtree;
 	struct dm_list *snh, *snht;
@@ -1254,8 +1254,9 @@
 }
 
 static int _add_snapshot_target_to_dtree(struct dev_manager *dm,
-					   struct dm_tree_node *dnode,
-					   struct logical_volume *lv)
+					 struct dm_tree_node *dnode,
+					 struct logical_volume *lv,
+					 struct lv_activate_opts *laopts)
 {
 	const char *origin_dlid;
 	const char *cow_dlid;
@@ -1288,8 +1289,9 @@
 }
 
 static int _add_target_to_dtree(struct dev_manager *dm,
-				  struct dm_tree_node *dnode,
-				  struct lv_segment *seg)
+				struct dm_tree_node *dnode,
+				struct lv_segment *seg,
+				struct lv_activate_opts *laopts)
 {
 	uint64_t extent_size = seg->lv->vg->extent_size;
 
@@ -1301,47 +1303,52 @@
 
 	return seg->segtype->ops->add_target_line(dm, dm->mem, dm->cmd,
 						  &dm->target_state, seg,
-						  dnode,
+						  laopts, dnode,
 						  extent_size * seg->len,
 						  &dm-> pvmove_mirror_count);
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				  struct logical_volume *lv, const char *layer);
+				struct logical_volume *lv,
+				struct lv_activate_opts *laopts,
+				const char *layer);
 
 /* Add all replicators' LVs */
 static int _add_replicator_dev_target_to_dtree(struct dev_manager *dm,
 					       struct dm_tree *dtree,
-					       struct lv_segment *seg)
+					       struct lv_segment *seg,
+					       struct lv_activate_opts *laopts)
 {
 	struct replicator_device *rdev;
 	struct replicator_site *rsite;
 
 	/* For inactive replicator add linear mapping */
 	if (!lv_is_active_replicator_dev(seg->lv)) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, NULL))
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv->rdevice->lv, laopts, NULL))
 			return_0;
 		return 1;
 	}
 
 	/* Add rlog and replicator nodes */
 	if (!seg->replicator ||
-            !first_seg(seg->replicator)->rlog_lv ||
+	    !first_seg(seg->replicator)->rlog_lv ||
 	    !_add_new_lv_to_dtree(dm, dtree,
-				  first_seg(seg->replicator)->rlog_lv, NULL) ||
-	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, NULL))
+				  first_seg(seg->replicator)->rlog_lv,
+				  laopts, NULL) ||
+	    !_add_new_lv_to_dtree(dm, dtree, seg->replicator, laopts, NULL))
 	    return_0;
 
 	/* Activation of one replicator_dev node activates all other nodes */
 	dm_list_iterate_items(rsite, &seg->replicator->rsites) {
 		dm_list_iterate_items(rdev, &rsite->rdevices) {
 			if (rdev->lv &&
-			    !_add_new_lv_to_dtree(dm, dtree, rdev->lv, NULL))
+			    !_add_new_lv_to_dtree(dm, dtree, rdev->lv,
+						  laopts, NULL))
 				return_0;
 
 			if (rdev->slog &&
-			    !_add_new_lv_to_dtree(dm, dtree,
-						  rdev->slog, NULL))
+			    !_add_new_lv_to_dtree(dm, dtree, rdev->slog,
+						  laopts, NULL))
 				return_0;
 		}
 	}
@@ -1356,7 +1363,7 @@
 			if (!rdev->replicator_dev->lv ||
 			    !_add_new_lv_to_dtree(dm, dtree,
 						  rdev->replicator_dev->lv,
-						  NULL))
+						  laopts, NULL))
 				return_0;
 		}
 	}
@@ -1365,10 +1372,11 @@
 }
 
 static int _add_segment_to_dtree(struct dev_manager *dm,
-				   struct dm_tree *dtree,
-				   struct dm_tree_node *dnode,
-				   struct lv_segment *seg,
-				   const char *layer)
+				 struct dm_tree *dtree,
+				 struct dm_tree_node *dnode,
+				 struct lv_segment *seg,
+				 struct lv_activate_opts *laopts,
+				 const char *layer)
 {
 	uint32_t s;
 	struct dm_list *snh;
@@ -1378,7 +1386,7 @@
 	/* Ensure required device-mapper targets are loaded */
 	seg_present = find_cow(seg->lv) ? : seg;
 	target_name = (seg_present->segtype->ops->target_name ?
-		       seg_present->segtype->ops->target_name(seg_present) :
+		       seg_present->segtype->ops->target_name(seg_present, laopts) :
 		       seg_present->segtype->name);
 
 	log_debug("Checking kernel supports %s segment type for %s%s%s",
@@ -1395,35 +1403,35 @@
 
 	/* Add mirror log */
 	if (seg->log_lv &&
-	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, NULL))
+	    !_add_new_lv_to_dtree(dm, dtree, seg->log_lv, laopts, NULL))
 		return_0;
 
 	if (seg_is_replicator_dev(seg)) {
-		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg))
+		if (!_add_replicator_dev_target_to_dtree(dm, dtree, seg, laopts))
 			return_0;
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
 	} else if (lv_is_origin(seg->lv) && !layer) {
 		if (lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
-			     find_merging_cow(seg->lv)->cow, "cow"))
+			     find_merging_cow(seg->lv)->cow, laopts, "cow"))
 				return_0;
 			/*
 			 * Must also add "real" LV for use when
 			 * snapshot-merge target is added
 			 */
 		}
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, "real"))
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "real"))
 			return_0;
 	} else if (lv_is_cow(seg->lv) && !layer) {
-		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, "cow"))
+		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
 	} else {
 		/* Add any LVs used by this segment */
 		for (s = 0; s < seg->area_count; s++)
 			if ((seg_type(seg, s) == AREA_LV) &&
 			    (!_add_new_lv_to_dtree(dm, dtree, seg_lv(seg, s),
-						   NULL)))
+						   laopts, NULL)))
 				return_0;
 	}
 
@@ -1437,22 +1445,24 @@
 				return_0;
 		}
 	} else if (lv_is_cow(seg->lv) && !layer) {
-		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv))
+		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv, laopts))
 			return_0;
-	} else if (!_add_target_to_dtree(dm, dnode, seg))
+	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
 		return_0;
 
 	if (lv_is_origin(seg->lv) && !layer)
 		/* Add any snapshots of this LV */
 		dm_list_iterate(snh, &seg->lv->snapshot_segs)
-			if (!_add_new_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, NULL))
+			if (!_add_new_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow,
+						  laopts, NULL))
 				return_0;
 
 	return 1;
 }
 
 static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-				struct logical_volume *lv, const char *layer)
+				struct logical_volume *lv, struct lv_activate_opts *laopts,
+				const char *layer)
 {
 	struct lv_segment *seg;
 	struct lv_layer *lvlayer;
@@ -1527,7 +1537,7 @@
 	/* Create table */
 	dm->pvmove_mirror_count = 0u;
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (!_add_segment_to_dtree(dm, dtree, dnode, seg, layer))
+		if (!_add_segment_to_dtree(dm, dtree, dnode, seg, laopts, layer))
 			return_0;
 		/* These aren't real segments in the LVM2 metadata */
 		if (lv_is_origin(lv) && !layer)
@@ -1551,7 +1561,7 @@
 	/* Add any LVs referencing a PVMOVE LV unless told not to */
 	if (dm->track_pvmove_deps && (lv->status & PVMOVE))
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
-			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, NULL))
+			if (!_add_new_lv_to_dtree(dm, dtree, sl->seg->lv, laopts, NULL))
 				return_0;
 
 	return 1;
@@ -1671,14 +1681,14 @@
 }
 
 static int _tree_action(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, action_t action)
+			struct lv_activate_opts *laopts, action_t action)
 {
 	struct dm_tree *dtree;
 	struct dm_tree_node *root;
 	char *dlid;
 	int r = 0;
 
-	if (!(dtree = _create_partial_dtree(dm, lv, origin_only)))
+	if (!(dtree = _create_partial_dtree(dm, lv, laopts->origin_only)))
 		return_0;
 
 	if (!(root = dm_tree_find_node(dtree, 0, 0))) {
@@ -1689,14 +1699,14 @@
 	/* Restore fs cookie */
 	dm_tree_set_cookie(root, fs_get_cookie());
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, origin_only ? "real" : NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, laopts->origin_only ? "real" : NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
 	switch(action) {
 	case CLEAN:
 		/* Deactivate any unused non-toplevel nodes */
-		if (!_clean_tree(dm, root, origin_only ? dlid : NULL))
+		if (!_clean_tree(dm, root, laopts->origin_only ? dlid : NULL))
 			goto_out;
 		break;
 	case DEACTIVATE:
@@ -1719,7 +1729,7 @@
 	case PRELOAD:
 	case ACTIVATE:
 		/* Add all required new devices to tree */
-		if (!_add_new_lv_to_dtree(dm, dtree, lv, origin_only ? "real" : NULL))
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, laopts->origin_only ? "real" : NULL))
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
@@ -1758,19 +1768,24 @@
 }
 
 /* origin_only may only be set if we are resuming (not activating) an origin LV */
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only)
+int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
+			 struct lv_activate_opts *laopts)
 {
-	if (!_tree_action(dm, lv, origin_only, ACTIVATE))
+	if (!_tree_action(dm, lv, laopts, ACTIVATE))
 		return_0;
 
-	return _tree_action(dm, lv, origin_only, CLEAN);
+	return _tree_action(dm, lv, laopts, CLEAN);
 }
 
 /* origin_only may only be set if we are resuming (not activating) an origin LV */
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int *flush_required)
+			struct lv_activate_opts *laopts, int *flush_required)
 {
-	if (!_tree_action(dm, lv, origin_only, PRELOAD))
+	/* FIXME Update the pvmove implementation! */
+	if ((lv->status & PVMOVE) || (lv->status & LOCKED))
+		return 1;
+
+	if (!_tree_action(dm, lv, laopts, PRELOAD))
 		return 0;
 
 	*flush_required = dm->flush_required;
@@ -1780,19 +1795,20 @@
 
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv)
 {
+	struct lv_activate_opts laopts = { 0 };
 	int r;
 
-	r = _tree_action(dm, lv, 0, DEACTIVATE);
+	r = _tree_action(dm, lv, &laopts, DEACTIVATE);
 
 	return r;
 }
 
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int lockfs, int flush_required)
+			struct lv_activate_opts *laopts, int lockfs, int flush_required)
 {
 	dm->flush_required = flush_required;
 
-	return _tree_action(dm, lv, origin_only, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
+	return _tree_action(dm, lv, laopts, lockfs ? SUSPEND_WITH_LOCKFS : SUSPEND);
 }
 
 /*
--- LVM2/lib/activate/dev_manager.h	2011/06/11 00:03:07	1.37
+++ LVM2/lib/activate/dev_manager.h	2011/06/17 14:14:19	1.38
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,6 +19,7 @@
 #include "metadata-exported.h"
 
 struct logical_volume;
+struct lv_activate_opts;
 struct volume_group;
 struct cmd_context;
 struct dev_manager;
@@ -52,10 +53,11 @@
 			       const struct logical_volume *lv, int wait,
 			       percent_t *percent, uint32_t *event_nr);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int lockfs, int flush_required);
-int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv, unsigned origin_only);
+			struct lv_activate_opts *laopts, int lockfs, int flush_required);
+int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
+			 struct lv_activate_opts *laopts);
 int dev_manager_preload(struct dev_manager *dm, struct logical_volume *lv,
-			unsigned origin_only, int *flush_required);
+			struct lv_activate_opts *laopts, int *flush_required);
 int dev_manager_deactivate(struct dev_manager *dm, struct logical_volume *lv);
 int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv) __attribute__((nonnull(1, 2)));
 
--- LVM2/lib/error/errseg.c	2011/03/25 21:59:42	1.23
+++ LVM2/lib/error/errseg.c	2011/06/17 14:14:19	1.24
@@ -45,6 +45,7 @@
 				struct cmd_context *cmd __attribute__((unused)),
 				void **target_state __attribute__((unused)),
 				struct lv_segment *seg __attribute__((unused)),
+				const struct lv_activate_opts *laopts __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
 				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
--- LVM2/lib/metadata/segtype.h	2010/12/20 13:32:49	1.34
+++ LVM2/lib/metadata/segtype.h	2011/06/17 14:14:20	1.35
@@ -22,6 +22,7 @@
 struct cmd_context;
 struct config_tree;
 struct lv_segment;
+struct lv_activate_opts;
 struct formatter;
 struct config_node;
 struct dev_manager;
@@ -66,7 +67,8 @@
 
 struct segtype_handler {
 	const char *(*name) (const struct lv_segment * seg);
-	const char *(*target_name) (const struct lv_segment * seg);
+	const char *(*target_name) (const struct lv_segment *seg,
+				    const struct lv_activate_opts *laopts);
 	void (*display) (const struct lv_segment * seg);
 	int (*text_export) (const struct lv_segment * seg,
 			    struct formatter * f);
@@ -78,10 +80,11 @@
 	int (*merge_segments) (struct lv_segment * seg1,
 			       struct lv_segment * seg2);
 	int (*add_target_line) (struct dev_manager *dm, struct dm_pool *mem,
-                                struct cmd_context *cmd, void **target_state,
-                                struct lv_segment *seg,
-                                struct dm_tree_node *node, uint64_t len,
-                                uint32_t *pvmove_mirror_count);
+				struct cmd_context *cmd, void **target_state,
+				struct lv_segment *seg,
+				const struct lv_activate_opts *laopts,
+				struct dm_tree_node *node, uint64_t len,
+				uint32_t *pvmove_mirror_count);
 	int (*target_status_compatible) (const char *type);
 	int (*check_transient_status) (struct lv_segment *seg, char *params);
 	int (*target_percent) (void **target_state,
--- LVM2/lib/mirror/mirrored.c	2011/05/07 13:32:06	1.87
+++ LVM2/lib/mirror/mirrored.c	2011/06/17 14:14:20	1.88
@@ -349,6 +349,7 @@
 }
 
 static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
+		    const struct lv_activate_opts *laopts,
 		    struct dm_tree_node *node, uint32_t area_count, uint32_t region_size)
 {
 	unsigned clustered = 0;
@@ -390,10 +391,11 @@
 }
 
 static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem,
-				struct cmd_context *cmd, void **target_state,
-				struct lv_segment *seg,
-				struct dm_tree_node *node, uint64_t len,
-				uint32_t *pvmove_mirror_count)
+				     struct cmd_context *cmd, void **target_state,
+				     struct lv_segment *seg,
+				     const struct lv_activate_opts *laopts,
+				     struct dm_tree_node *node, uint64_t len,
+				     uint32_t *pvmove_mirror_count)
 {
 	struct mirror_state *mirr_state;
 	uint32_t area_count = seg->area_count;
@@ -451,7 +453,7 @@
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;
 
-	if ((r = _add_log(mem, seg, node, area_count, region_size)) <= 0) {
+	if ((r = _add_log(mem, seg, laopts, node, area_count, region_size)) <= 0) {
 		stack;
 		return r;
 	}
--- LVM2/lib/replicator/replicator.c	2011/03/25 21:59:42	1.6
+++ LVM2/lib/replicator/replicator.c	2011/06/17 14:14:20	1.7
@@ -327,6 +327,7 @@
 				       struct cmd_context *cmd,
 				       void **target_state,
 				       struct lv_segment *seg,
+				       const struct lv_activate_opts *laopts,
 				       struct dm_tree_node *node,
 				       uint64_t len,
 				       uint32_t *pvmove_mirror_count)
@@ -609,6 +610,7 @@
 					   struct cmd_context *cmd,
 					   void **target_state,
 					   struct lv_segment *seg,
+					   const struct lv_activate_opts *laopts,
 					   struct dm_tree_node *node,
 					   uint64_t len,
 					   uint32_t *pvmove_mirror_count)
--- LVM2/lib/snapshot/snapshot.c	2011/04/29 00:21:15	1.55
+++ LVM2/lib/snapshot/snapshot.c	2011/06/17 14:14:20	1.56
@@ -28,7 +28,8 @@
 	return seg->segtype->name;
 }
 
-static const char *_snap_target_name(const struct lv_segment *seg)
+static const char *_snap_target_name(const struct lv_segment *seg,
+				     const struct lv_activate_opts *laopts)
 {
 	if (seg->status & MERGING)
 		return "snapshot-merge";
--- LVM2/lib/striped/striped.c	2011/03/25 21:59:43	1.36
+++ LVM2/lib/striped/striped.c	2011/06/17 14:14:20	1.37
@@ -164,6 +164,7 @@
 				struct cmd_context *cmd __attribute__((unused)),
 				void **target_state __attribute__((unused)),
 				struct lv_segment *seg,
+				const struct lv_activate_opts *laopts __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
 				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
--- LVM2/lib/unknown/unknown.c	2011/03/25 21:59:43	1.5
+++ LVM2/lib/unknown/unknown.c	2011/06/17 14:14:21	1.6
@@ -67,6 +67,7 @@
 				struct cmd_context *cmd __attribute__((unused)),
 				void **target_state __attribute__((unused)),
 				struct lv_segment *seg __attribute__((unused)),
+				const struct lv_activate_opts *laopts __attribute__((unused)),
 				struct dm_tree_node *node, uint64_t len,
 				uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
--- LVM2/lib/zero/zero.c	2011/03/25 21:59:43	1.24
+++ LVM2/lib/zero/zero.c	2011/06/17 14:14:21	1.25
@@ -44,6 +44,7 @@
 				 struct cmd_context *cmd __attribute__((unused)),
 				 void **target_state __attribute__((unused)),
 				 struct lv_segment *seg __attribute__((unused)),
+				 const struct lv_activate_opts *laopts __attribute__((unused)),
 				 struct dm_tree_node *node,uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {


