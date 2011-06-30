From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2011 18:25:19 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20110630182519.16653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-30 18:25:19

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c 
	lib/metadata   : lv_manip.c metadata.h 

Log message:
	When suspending, automatically preload newly-visible existing LVs
	Let's find out if this makes things better or worse overall...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2033&r2=1.2034
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.203&r2=1.204
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.220&r2=1.221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.265&r2=1.266
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.246&r2=1.247

--- LVM2/WHATS_NEW	2011/06/30 09:24:58	1.2033
+++ LVM2/WHATS_NEW	2011/06/30 18:25:18	1.2034
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  When suspending, automatically preload newly-visible existing LVs.
   Report internal error when parameters are missing on table load.
   Teardown any stray devices with $COMMON_PREFIX during test runs.
   Reinstate correct permissions when creating mirrors. [2.02.85]
--- LVM2/lib/activate/activate.c	2011/06/22 21:31:21	1.203
+++ LVM2/lib/activate/activate.c	2011/06/30 18:25:18	1.204
@@ -1097,6 +1097,26 @@
 #endif
 }
 
+struct detached_lv_data {
+	struct logical_volume *lv_pre;
+	struct lv_activate_opts *laopts;
+	int *flush_required;
+};
+
+static int _preload_detached_lv(struct cmd_context *cmd, struct logical_volume *lv, void *data)
+{
+	struct detached_lv_data *detached = data;
+	struct lv_list *lvl_pre;
+
+	if ((lvl_pre = find_lv_in_vg(detached->lv_pre->vg, lv->name))) {
+		if (lv_is_visible(lvl_pre->lv) && lv_is_active(lv) &&
+		    !_lv_preload(lvl_pre->lv, detached->laopts, detached->flush_required))
+			return_0;
+	}
+
+	return 1;
+}
+
 static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		       struct lv_activate_opts *laopts, int error_if_not_suspended)
 {
@@ -1105,6 +1125,7 @@
 	struct seg_list *sl;
 	struct lvinfo info;
 	int r = 0, lockfs = 0, flush_required = 0;
+	struct detached_lv_data detached;
 
 	if (!activation())
 		return 1;
@@ -1172,9 +1193,21 @@
 			}
 			if (!_lv_preload(lvl_pre->lv, laopts, &flush_required))
 				goto_out;
-		} else if (!_lv_preload(lv_pre, laopts, &flush_required))
-			/* FIXME Revert preloading */
-			goto_out;
+		} else {
+			if (!_lv_preload(lv_pre, laopts, &flush_required))
+				/* FIXME Revert preloading */
+				goto_out;
+
+			/*
+			 * Search for existing LVs that have become detached and preload them.
+			 */
+			detached.lv_pre = lv_pre;
+			detached.laopts = laopts;
+			detached.flush_required = &flush_required;
+
+			if (!for_each_sub_lv(cmd, lv, &_preload_detached_lv, &detached))
+				goto_out;
+		}
 	}
 
 	if (!monitor_dev_for_events(cmd, lv, laopts, 0))
--- LVM2/lib/activate/dev_manager.c	2011/06/17 14:50:53	1.220
+++ LVM2/lib/activate/dev_manager.c	2011/06/30 18:25:18	1.221
@@ -1096,11 +1096,11 @@
 		return NULL;
 	}
 
-	if (!_add_lv_to_dtree(dm, dtree, lv, origin_only))
+	if (!_add_lv_to_dtree(dm, dtree, lv, lv_is_origin(lv) ? origin_only : 0))
 		goto_bad;
 
 	/* Add any snapshots of this LV */
-	if (!origin_only)
+	if (!origin_only && lv_is_origin(lv))
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs)
 			if (!_add_lv_to_dtree(dm, dtree, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, 0))
 				goto_bad;
@@ -1714,7 +1714,7 @@
 	/* Restore fs cookie */
 	dm_tree_set_cookie(root, fs_get_cookie());
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, laopts->origin_only ? "real" : NULL)))
+	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, (lv_is_origin(lv) && laopts->origin_only) ? "real" : NULL)))
 		goto_out;
 
 	/* Only process nodes with uuid of "LVM-" plus VG id. */
@@ -1744,7 +1744,7 @@
 	case PRELOAD:
 	case ACTIVATE:
 		/* Add all required new devices to tree */
-		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, laopts->origin_only ? "real" : NULL))
+		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, (lv_is_origin(lv) && laopts->origin_only) ? "real" : NULL))
 			goto_out;
 
 		/* Preload any devices required before any suspensions */
--- LVM2/lib/metadata/lv_manip.c	2011/06/29 17:05:53	1.265
+++ LVM2/lib/metadata/lv_manip.c	2011/06/30 18:25:18	1.266
@@ -2317,7 +2317,7 @@
 	return _rename_single_lv(lv, new_name);
 }
 
-/* Callback for _for_each_sub_lv */
+/* Callback for for_each_sub_lv */
 static int _rename_cb(struct cmd_context *cmd, struct logical_volume *lv,
 		      void *data)
 {
@@ -2327,32 +2327,31 @@
 }
 
 /*
- * Loop down sub LVs and call "func" for each.
- * "func" is responsible to log necessary information on failure.
+ * Loop down sub LVs and call fn for each.
+ * fn is responsible to log necessary information on failure.
  */
-static int _for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
-			    int (*func)(struct cmd_context *cmd,
-					struct logical_volume *lv,
-					void *data),
-			    void *data)
+int for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
+		    int (*fn)(struct cmd_context *cmd,
+			      struct logical_volume *lv, void *data),
+		    void *data)
 {
 	struct logical_volume *org;
 	struct lv_segment *seg;
 	uint32_t s;
 
 	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv)))
-		if (!func(cmd, org, data))
+		if (!fn(cmd, org, data))
 			return_0;
 
 	dm_list_iterate_items(seg, &lv->segments) {
-		if (seg->log_lv && !func(cmd, seg->log_lv, data))
+		if (seg->log_lv && !fn(cmd, seg->log_lv, data))
 			return_0;
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
-			if (!func(cmd, seg_lv(seg, s), data))
+			if (!fn(cmd, seg_lv(seg, s), data))
 				return_0;
-			if (!_for_each_sub_lv(cmd, seg_lv(seg, s), func, data))
+			if (!for_each_sub_lv(cmd, seg_lv(seg, s), fn, data))
 				return_0;
 		}
 	}
@@ -2397,7 +2396,7 @@
 	/* rename sub LVs */
 	lv_names.old = lv->name;
 	lv_names.new = new_name;
-	if (!_for_each_sub_lv(cmd, lv, _rename_cb, (void *) &lv_names))
+	if (!for_each_sub_lv(cmd, lv, _rename_cb, (void *) &lv_names))
 		return 0;
 
 	/* rename main LV */
--- LVM2/lib/metadata/metadata.h	2011/06/17 14:30:58	1.246
+++ LVM2/lib/metadata/metadata.h	2011/06/30 18:25:18	1.247
@@ -441,6 +441,11 @@
 int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 
+int for_each_sub_lv(struct cmd_context *cmd, struct logical_volume *lv,
+                    int (*fn)(struct cmd_context *cmd,
+                              struct logical_volume *lv, void *data),
+                    void *data);
+
 /*
  * Calculate readahead from underlying PV devices
  */


