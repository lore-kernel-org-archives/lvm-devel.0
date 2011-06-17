From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 17 Jun 2011 14:22:50 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20110617142250.2835.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-17 14:22:49

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c dev_manager.c 
	lib/snapshot   : snapshot.c 

Log message:
	Use lv_activate_opts struct instead of ACTIVATE_EXCL status flag
	
	Let's hope all conditions has been properly converted.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2018&r2=1.2019
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.199&r2=1.200
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.218&r2=1.219
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/snapshot.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2011/06/17 14:17:16	1.2018
+++ LVM2/WHATS_NEW	2011/06/17 14:22:48	1.2019
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Use lv_activate_opts struct instead of MERGING status flag.
   Use lv_activate_opts struct instead of ACTIVATE_EXCL status flag.
   Add lv_activate_opts structure for activation (replacing activation flags).
   Fix a problem with inconsistent pre-commit metadata on MISSING_PV devices.
--- LVM2/lib/activate/activate.c	2011/06/17 14:14:19	1.199
+++ LVM2/lib/activate/activate.c	2011/06/17 14:22:48	1.200
@@ -986,8 +986,8 @@
 	 * In case of a snapshot device, we monitor lv->snapshot->lv,
 	 * not the actual LV itself.
 	 */
-	if (lv_is_cow(lv) && !lv_is_merging_cow(lv))
-		return monitor_dev_for_events(cmd, lv->snapshot->lv, 0, monitor);
+	if (lv_is_cow(lv) && (laopts->no_merging || !lv_is_merging_cow(lv)))
+		return monitor_dev_for_events(cmd, lv->snapshot->lv, NULL, monitor);
 
 	/*
 	 * In case this LV is a snapshot origin, we instead monitor
--- LVM2/lib/activate/dev_manager.c	2011/06/17 14:14:19	1.218
+++ LVM2/lib/activate/dev_manager.c	2011/06/17 14:22:48	1.219
@@ -1276,7 +1276,7 @@
 
 	size = (uint64_t) snap_seg->len * snap_seg->origin->vg->extent_size;
 
-	if (lv_is_merging_cow(lv)) {
+	if (!laopts->no_merging && lv_is_merging_cow(lv)) {
 		/* cow is to be merged so load the error target */
 		if (!dm_tree_node_add_error_target(dnode, size))
 			return_0;
@@ -1412,7 +1412,7 @@
 	/* If this is a snapshot origin, add real LV */
 	/* If this is a snapshot origin + merging snapshot, add cow + real LV */
 	} else if (lv_is_origin(seg->lv) && !layer) {
-		if (lv_is_merging_origin(seg->lv)) {
+		if (!laopts->no_merging && lv_is_merging_origin(seg->lv)) {
 			if (!_add_new_lv_to_dtree(dm, dtree,
 			     find_merging_cow(seg->lv)->cow, laopts, "cow"))
 				return_0;
@@ -1423,7 +1423,7 @@
 		}
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "real"))
 			return_0;
-	} else if (lv_is_cow(seg->lv) && !layer) {
+	} else if (!laopts->no_merging && lv_is_cow(seg->lv) && !layer) {
 		if (!_add_new_lv_to_dtree(dm, dtree, seg->lv, laopts, "cow"))
 			return_0;
 	} else {
@@ -1437,14 +1437,14 @@
 
 	/* Now we've added its dependencies, we can add the target itself */
 	if (lv_is_origin(seg->lv) && !layer) {
-		if (!lv_is_merging_origin(seg->lv)) {
+		if (laopts->no_merging || !lv_is_merging_origin(seg->lv)) {
 			if (!_add_origin_target_to_dtree(dm, dnode, seg->lv))
 				return_0;
 		} else {
 			if (!_add_snapshot_merge_target_to_dtree(dm, dnode, seg->lv))
 				return_0;
 		}
-	} else if (lv_is_cow(seg->lv) && !layer) {
+	} else if (!laopts->no_merging && lv_is_cow(seg->lv) && !layer) {
 		if (!_add_snapshot_target_to_dtree(dm, dnode, seg->lv, laopts))
 			return_0;
 	} else if (!_add_target_to_dtree(dm, dnode, seg, laopts))
@@ -1490,7 +1490,7 @@
 					   dtree)) && dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
 			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))
-				clear_snapshot_merge(lv);
+				laopts->no_merging = 1;
 		}
 	}
 
@@ -1542,7 +1542,7 @@
 		/* These aren't real segments in the LVM2 metadata */
 		if (lv_is_origin(lv) && !layer)
 			break;
-		if (lv_is_cow(lv) && !layer)
+		if (!laopts->no_merging && lv_is_cow(lv) && !layer)
 			break;
 		if (max_stripe_size < seg->stripe_size * seg->area_count)
 			max_stripe_size = seg->stripe_size * seg->area_count;
--- LVM2/lib/snapshot/snapshot.c	2011/06/17 14:14:20	1.56
+++ LVM2/lib/snapshot/snapshot.c	2011/06/17 14:22:49	1.57
@@ -31,7 +31,7 @@
 static const char *_snap_target_name(const struct lv_segment *seg,
 				     const struct lv_activate_opts *laopts)
 {
-	if (seg->status & MERGING)
+	if (!laopts->no_merging && (seg->status & MERGING))
 		return "snapshot-merge";
 
 	return _snap_name(seg);


