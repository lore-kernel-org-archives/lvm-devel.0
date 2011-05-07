From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 May 2011 13:56:16 -0000
Subject: LVM2/tools lvconvert.c lvconvert.h
Message-ID: <20110507135616.5404.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-07 13:56:13

Modified files:
	tools          : lvconvert.c 
Added files:
	tools          : lvconvert.h 

Log message:
	Add a new entry point in the mirror lvconvert code, for removing missing mirror
	images and/or logs, without attempting any further actions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162

/cvs/lvm2/LVM2/tools/lvconvert.h,v  -->  standard output
revision 1.1
--- LVM2/tools/lvconvert.h
+++ -	2011-05-07 13:56:14.461143000 +0000
@@ -0,0 +1,2 @@
+int mirror_remove_missing(struct cmd_context *cmd,
+			  struct logical_volume *lv, int force);
--- LVM2/tools/lvconvert.c	2011/04/09 19:05:24	1.161
+++ LVM2/tools/lvconvert.c	2011/05/07 13:56:13	1.162
@@ -16,6 +16,7 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "metadata.h"
+#include "lvconvert.h"
 
 struct lvconvert_params {
 	int snapshot;
@@ -46,7 +47,6 @@
 	int pv_count;
 	char **pvs;
 	struct dm_list *pvh;
-	struct dm_list *failed_pvs;
 
 	struct logical_volume *lv_to_poll;
 };
@@ -319,7 +319,6 @@
 
 	lp->pv_count = argc;
 	lp->pvs = argv;
-	lp->failed_pvs = NULL;
 
 	return 1;
 }
@@ -538,19 +537,6 @@
 	return 1;
 }
 
-static int _area_missing(struct lv_segment *lvseg, int s)
-{
-	if (seg_type(lvseg, s) == AREA_LV) {
-		if (seg_lv(lvseg, s)->status & PARTIAL_LV)
-			return 1;
-	} else if ((seg_type(lvseg, s) == AREA_PV) &&
-		   (is_missing_pv(seg_pv(lvseg, s))))
-		return 1;
-
-	return 0;
-}
-
-/* FIXME we want to handle mirror stacks here... */
 static int _failed_mirrors_count(struct logical_volume *lv)
 {
 	struct lv_segment *lvseg;
@@ -560,14 +546,41 @@
 	dm_list_iterate_items(lvseg, &lv->segments) {
 		if (!seg_is_mirrored(lvseg))
 			return -1;
-		for (s = 0; s < lvseg->area_count; s++)
-			if (_area_missing(lvseg, s))
-				ret++;
+		for (s = 0; s < lvseg->area_count; s++) {
+			if (seg_type(lvseg, s) == AREA_LV) {
+				if (is_temporary_mirror_layer(seg_lv(lvseg, s)))
+					ret += _failed_mirrors_count(seg_lv(lvseg, s));
+				else if (seg_lv(lvseg, s)->status & PARTIAL_LV)
+					++ ret;
+				else if (seg_type(lvseg, s) == AREA_PV &&
+					 is_missing_pv(seg_pv(lvseg, s)))
+					++ret;
+			}
+		}
 	}
 
 	return ret;
 }
 
+static int _failed_logs_count(struct logical_volume *lv)
+{
+	int ret = 0, s;
+	struct logical_volume *log_lv = first_seg(lv)->log_lv;
+	if (log_lv && (log_lv->status & PARTIAL_LV)) {
+		if (log_lv->status & MIRRORED)
+			ret += _failed_mirrors_count(log_lv);
+		else
+			ret += 1;
+	}
+	for (s = 0; s < first_seg(lv)->area_count; s++) {
+		if (seg_type(first_seg(lv), s) == AREA_LV &&
+		    is_temporary_mirror_layer(seg_lv(first_seg(lv), s)))
+			ret += _failed_logs_count(seg_lv(first_seg(lv), s));
+	}
+	return ret;
+}
+
+
 static struct dm_list *_failed_pv_list(struct volume_group *vg)
 {
 	struct dm_list *failed_pvs;
@@ -684,10 +697,10 @@
 	struct logical_volume *log_lv;
 
 	log_lv = first_seg(_original_lv(lv))->log_lv;
-	if (!log_lv)
-		return 0;
+	if (log_lv)
+		return lv_mirror_count(log_lv);
 
-	return lv_mirror_count(log_lv);
+	return 0;
 }
 
 static int _lv_update_mirrored_log(struct logical_volume *lv,
@@ -735,10 +748,6 @@
 		return 1;
 
 	original_lv = _original_lv(lv);
-	region_size = adjusted_mirror_region_size(lv->vg->extent_size,
-						  lv->le_count,
-						  lp->region_size);
-
 	/* Remove an existing log completely */
 	if (!log_count) {
 		if (!remove_mirror_log(cmd, original_lv, operable_pvs,
@@ -752,6 +761,11 @@
 
 	/* Adding redundancy to the log */
 	if (old_log_count < log_count) {
+
+		region_size = adjusted_mirror_region_size(lv->vg->extent_size,
+							  lv->le_count,
+							  lp->region_size);
+
 		if (!add_mirror_log(cmd, original_lv, log_count,
 				    region_size, operable_pvs, lp->alloc))
 			return_0;
@@ -1168,6 +1182,47 @@
 	return 1;
 }
 
+int mirror_remove_missing(struct cmd_context *cmd,
+			  struct logical_volume *lv, int force)
+{
+	struct dm_list *failed_pvs;
+	int log_count = _get_log_count(lv) - _failed_logs_count(lv);
+
+	if (!(failed_pvs = _failed_pv_list(lv->vg)))
+		return_0;
+
+	/* No point in keeping a log if the result is not a mirror */
+	if (_failed_mirrors_count(lv) + 1 >= lv_mirror_count(lv))
+		log_count = 0;
+
+        if (force && _failed_mirrors_count(lv) == lv_mirror_count(lv)) {
+		log_error("No usable images left in %s.", lv->name);
+		return lv_remove_with_dependencies(cmd, lv, 1, 0);
+        }
+
+	/*
+	 * We must adjust the log first, or the entire mirror
+	 * will get stuck during a suspend.
+	 */
+	if (!_lv_update_mirrored_log(lv, failed_pvs, log_count))
+		return 0;
+
+	if (_failed_mirrors_count(lv) > 0 &&
+	    !lv_remove_mirrors(cmd, lv, _failed_mirrors_count(lv),
+			       log_count ? 0U : 1U,
+			       _is_partial_lv, NULL, 0))
+		return 0;
+
+	if (!_lv_update_log_type(cmd, NULL, lv, failed_pvs,
+				 log_count))
+		return 0;
+
+	if (!_reload_lv(cmd, lv))
+		return 0;
+
+	return 1;
+}
+
 /*
  * _lvconvert_mirrors_repair
  *
@@ -1180,16 +1235,16 @@
  */
 static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 				     struct logical_volume *lv,
-				     struct lvconvert_params *lp,
-				     uint32_t old_mimage_count,
-				     uint32_t old_log_count)
-{
-	int failed_log = 0;
-	int failed_mirrors = 0;
-	int replace_log = 0;
-	int replace_mirrors = 0;
-	uint32_t new_log_count, log_count;
-	struct logical_volume *log_lv;
+				     struct lvconvert_params *lp)
+{
+	int failed_logs = 0;
+	int failed_mimages = 0;
+	int replace_logs = 0;
+	int replace_mimages = 0;
+	uint32_t log_count;
+
+	uint32_t original_mimages = lv_mirror_count(lv);
+	uint32_t original_logs = _get_log_count(lv);
 
 	cmd->handles_missing_pvs = 1;
 	cmd->partial_activation = 1;
@@ -1202,93 +1257,43 @@
 		return 1;
 	}
 
-	/*
-	 * Count the failed mimages - negative if 'lv' is not a mirror
-	 */
-	if ((failed_mirrors = _failed_mirrors_count(lv)) < 0)
-		return_0;
+	failed_mimages = _failed_mirrors_count(lv);
+	failed_logs = _failed_logs_count(lv);
 
-	lp->mirrors = old_mimage_count - failed_mirrors;
+	mirror_remove_missing(cmd, lv, 0);
 
-	if (lp->mirrors != old_mimage_count)
+	if (failed_mimages)
 		log_error("Mirror status: %d of %d images failed.",
-			  failed_mirrors, old_mimage_count);
+			  failed_mimages, original_mimages);
 
 	/*
 	 * Count the failed log devices
 	 */
-	new_log_count = old_log_count;
-	log_lv = first_seg(lv)->log_lv;
-	if (log_lv) {
-		new_log_count = lv_mirror_count(log_lv);
-		if (log_lv->status & PARTIAL_LV) {
-			failed_log = 1;
-			if (log_lv->status & MIRRORED)
-				new_log_count -= _failed_mirrors_count(log_lv);
-			else
-				new_log_count = 0;
-		}
-	}
-	if (old_log_count != new_log_count)
-		log_error("Mirror log status: %d of %d images failed%s",
-			  old_log_count - new_log_count, old_log_count,
-			  (!new_log_count) ? " - switching to core" : "");
+	if (failed_logs)
+		log_error("Mirror log status: %d of %d images failed.",
+			  failed_logs, original_logs);
 
 	/*
 	 * Find out our policies
 	 */
-	_lvconvert_mirrors_repair_ask(cmd, failed_log, failed_mirrors,
-				      &replace_log, &replace_mirrors);
-
-	/*
-	 * First phase - remove faulty devices
-	 */
-	if (!(lp->failed_pvs = _failed_pv_list(lv->vg)))
-		return_0;
-
-	log_count = new_log_count;
-
-	/*
-	 * We must adjust the log first, or the entire mirror
-	 * will get stuck during a suspend.
-	 */
-	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, log_count))
-		return 0;
-
-	if (lp->mirrors == 1)
-		log_count = 0;
-
-	if (failed_mirrors) {
-		if (!lv_remove_mirrors(cmd, lv, failed_mirrors,
-				       log_count ? 0U : 1U,
-				       _is_partial_lv, NULL, 0))
-			return 0;
-	}
-
-	if (!_lv_update_log_type(cmd, lp, lv, lp->failed_pvs,
-				 log_count))
-		return 0;
-
-	if (!_reload_lv(cmd, lv))
-		return 0;
+	_lvconvert_mirrors_repair_ask(cmd, failed_logs, failed_mimages,
+				      &replace_logs, &replace_mimages);
 
 	/*
 	 * Second phase - replace faulty devices
 	 */
-
-	if (replace_mirrors)
-		lp->mirrors = old_mimage_count;
+	lp->mirrors = replace_mimages ? original_mimages : (original_mimages - failed_mimages);
 
 	/*
 	 * It does not make sense to replace the log if the volume is no longer
 	 * a mirror.
 	 */
-	if (!replace_mirrors && lp->mirrors == 1)
-		replace_log = 0;
+	if (lp->mirrors == 1)
+		replace_logs = 0;
 
-	log_count = replace_log ? old_log_count : new_log_count;
+	log_count = replace_logs ? original_logs : (original_logs - failed_logs);
 
-	while (replace_mirrors || replace_log) {
+	while (replace_mimages || replace_logs) {
 		log_warn("Trying to up-convert to %d images, %d logs.", lp->mirrors, log_count);
 		if (_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 					   lp->mirrors, log_count))
@@ -1303,12 +1308,12 @@
 		}
 	}
 
-	if (replace_mirrors && lp->mirrors != old_mimage_count)
+	if (replace_mimages && lv_mirror_count(lv) != original_mimages)
 		log_warn("WARNING: Failed to replace %d of %d images in volume %s",
-			 old_mimage_count - lp->mirrors, old_mimage_count, lv->name);
-	if (replace_log && log_count != old_log_count)
+			 original_mimages - lv_mirror_count(lv), original_mimages, lv->name);
+	if (replace_logs && _get_log_count(lv) != original_logs)
 		log_warn("WARNING: Failed to replace %d of %d logs in volume %s",
-			 old_log_count - log_count, old_log_count, lv->name);
+			 original_logs - _get_log_count(lv), original_logs, lv->name);
 
 	/* if (!arg_count(cmd, use_policies_ARG) && (lp->mirrors != old_mimage_count
 						  || log_count != old_log_count))
@@ -1354,9 +1359,7 @@
 		return 1;
 
 	if (repair)
-		return _lvconvert_mirrors_repair(cmd, lv, lp,
-						 old_mimage_count,
-						 old_log_count);
+		return _lvconvert_mirrors_repair(cmd, lv, lp);
 
 	if (!_lvconvert_mirrors_aux(cmd, lv, lp, NULL,
 				    new_mimage_count, new_log_count))
@@ -1531,6 +1534,7 @@
 			     void *handle)
 {
 	struct lvconvert_params *lp = handle;
+	struct dm_list *failed_pvs;
 
 	if (lv->status & LOCKED) {
 		log_error("Cannot convert locked LV %s", lv->name);
@@ -1594,9 +1598,14 @@
 			return ECMD_FAILED;
 		}
 
+		if (!(failed_pvs = _failed_pv_list(lv->vg))) {
+			stack;
+			return ECMD_FAILED;
+		}
+
 		/* If repairing and using policies, remove missing PVs from VG */
 		if (arg_count(cmd, repair_ARG) && arg_count(cmd, use_policies_ARG))
-			_remove_missing_empty_pv(lv->vg, lp->failed_pvs);
+			_remove_missing_empty_pv(lv->vg, failed_pvs);
 	}
 
 	return ECMD_PROCESSED;


