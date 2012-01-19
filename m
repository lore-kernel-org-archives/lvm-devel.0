From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:23:52 -0000
Subject: LVM2/lib activate/dev_manager.c display/displa ...
Message-ID: <20120119152352.26486.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:23:51

Modified files:
	lib/activate   : dev_manager.c 
	lib/display    : display.c 
	lib/metadata   : lv_manip.c merge.c metadata-exported.h 
	                 thin_manip.c 
	lib/thin       : thin.c 

Log message:
	Thin rename seg var  pool_metadata_lv to metadata_lv
	
	Better fits the code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.258&r2=1.259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.340&r2=1.341
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.225&r2=1.226
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/lib/activate/dev_manager.c	2012/01/19 15:19:18	1.258
+++ LVM2/lib/activate/dev_manager.c	2012/01/19 15:23:50	1.259
@@ -1160,7 +1160,7 @@
 		return_0;
 
 	if (lv_is_thin_pool(lv)) {
-		if (!_add_lv_to_dtree(dm, dtree, seg->pool_metadata_lv, origin_only))
+		if (!_add_lv_to_dtree(dm, dtree, seg->metadata_lv, origin_only))
 			return_0;
 		/* FIXME code from _create_partial_dtree() should be moved here */
 		if (!_add_lv_to_dtree(dm, dtree, seg_lv(seg, 0), origin_only))
@@ -1566,7 +1566,7 @@
 			return_0;
 	} else {
 		if (seg_is_thin_pool(seg) &&
-		    !_add_new_lv_to_dtree(dm, dtree, seg->pool_metadata_lv, laopts, NULL))
+		    !_add_new_lv_to_dtree(dm, dtree, seg->metadata_lv, laopts, NULL))
 			return_0;
 
 		/* Add any LVs used by this segment */
--- LVM2/lib/display/display.c	2012/01/12 16:58:44	1.123
+++ LVM2/lib/display/display.c	2012/01/19 15:23:50	1.124
@@ -564,7 +564,7 @@
 		log_print("LV Thin transaction ID %" PRIu64,
 			  first_seg(lv)->transaction_id);
 		log_print("LV Thin metadata       %s%s/%s", lv->vg->cmd->dev_dir,
-			  lv->vg->name, first_seg(lv)->pool_metadata_lv->name);
+			  lv->vg->name, first_seg(lv)->metadata_lv->name);
 		log_print("LV Thin data pool      %s%s/%s", lv->vg->cmd->dev_dir,
 			  lv->vg->name, seg_lv(first_seg(lv), 0)->name);
 		log_print("LV Zero new blocks     %s",
--- LVM2/lib/metadata/lv_manip.c	2011/12/21 12:54:19	1.340
+++ LVM2/lib/metadata/lv_manip.c	2012/01/19 15:23:50	1.341
@@ -523,7 +523,7 @@
 			if (seg->log_lv && !lv_remove(seg->log_lv))
 				return_0;
 
-			if (seg->pool_metadata_lv && !lv_remove(seg->pool_metadata_lv))
+			if (seg->metadata_lv && !lv_remove(seg->metadata_lv))
 				return_0;
 
 			if (seg->pool_lv) {
@@ -2788,7 +2788,7 @@
 			if (!for_each_sub_lv(cmd, seg->log_lv, fn, data))
 				return_0;
 		}
-		if (seg->pool_metadata_lv && !fn(cmd, seg->pool_metadata_lv, data))
+		if (seg->metadata_lv && !fn(cmd, seg->metadata_lv, data))
 			return_0;
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
--- LVM2/lib/metadata/merge.c	2011/11/07 11:03:47	1.55
+++ LVM2/lib/metadata/merge.c	2012/01/19 15:23:51	1.56
@@ -102,7 +102,7 @@
 
 		if (lv_is_thin_pool_metadata(lv) &&
 		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
-		     seg2->pool_metadata_lv != lv)) {
+		     seg2->metadata_lv != lv)) {
 			log_error("LV %s: segment 1 pool metadata LV does not point back to same LV",
 				  lv->name);
 			inc_error_count;
@@ -191,11 +191,11 @@
 					inc_error_count;
 				}
 
-				if (!seg->pool_metadata_lv) {
+				if (!seg->metadata_lv) {
 					log_error("LV %s: thin pool segment %u is missing a pool metadata LV",
 						  lv->name, seg_count);
 					inc_error_count;
-				} else if (!(seg2 = first_seg(seg->pool_metadata_lv)) ||
+				} else if (!(seg2 = first_seg(seg->metadata_lv)) ||
 					   find_pool_seg(seg2) != seg) {
 					log_error("LV %s: thin pool segment %u metadata LV does not refer back to pool LV",
 						  lv->name, seg_count);
@@ -209,7 +209,7 @@
 					inc_error_count;
 				}
 			} else {
-				if (seg->pool_metadata_lv) {
+				if (seg->metadata_lv) {
 					log_error("LV %s: segment %u must not have thin pool metadata LV set",
 						  lv->name, seg_count);
 					inc_error_count;
@@ -371,7 +371,7 @@
 				seg_found++;
 		if (seg->log_lv == lv)
 			seg_found++;
-		if (seg->pool_metadata_lv == lv || seg->pool_lv == lv)
+		if (seg->metadata_lv == lv || seg->pool_lv == lv)
 			seg_found++;
 		if (seg_is_thin_volume(seg) && seg->origin == lv)
 			seg_found++;
--- LVM2/lib/metadata/metadata-exported.h	2011/12/01 00:09:35	1.225
+++ LVM2/lib/metadata/metadata-exported.h	2012/01/19 15:23:51	1.226
@@ -345,7 +345,7 @@
 
 	struct lv_segment_area *areas;
 	struct lv_segment_area *meta_areas;	/* For RAID */
-	struct logical_volume *pool_metadata_lv;/* For thin_pool */
+	struct logical_volume *metadata_lv;	/* For thin_pool */
 	uint64_t transaction_id;		/* For thin_pool, thin */
 	uint64_t low_water_mark;		/* For thin_pool */
 	uint32_t data_block_size;		/* For thin_pool, 128..2097152 */
--- LVM2/lib/metadata/thin_manip.c	2011/12/10 00:47:23	1.27
+++ LVM2/lib/metadata/thin_manip.c	2012/01/19 15:23:51	1.28
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -20,13 +20,13 @@
 #include "lv_alloc.h"
 #include "archiver.h"
 
-int attach_pool_metadata_lv(struct lv_segment *seg, struct logical_volume *pool_metadata_lv)
+int attach_pool_metadata_lv(struct lv_segment *seg, struct logical_volume *metadata_lv)
 {
-	seg->pool_metadata_lv = pool_metadata_lv;
-	pool_metadata_lv->status |= THIN_POOL_METADATA;
-	lv_set_hidden(pool_metadata_lv);
+	seg->metadata_lv = metadata_lv;
+	metadata_lv->status |= THIN_POOL_METADATA;
+	lv_set_hidden(metadata_lv);
 
-	return add_seg_to_segs_using_this_lv(pool_metadata_lv, seg);
+	return add_seg_to_segs_using_this_lv(metadata_lv, seg);
 }
 
 int attach_pool_data_lv(struct lv_segment *seg, struct logical_volume *pool_data_lv)
--- LVM2/lib/thin/thin.c	2012/01/19 15:21:23	1.38
+++ LVM2/lib/thin/thin.c	2012/01/19 15:23:51	1.39
@@ -152,7 +152,7 @@
 	unsigned cnt = 0;
 	const struct lv_thin_message *tmsg;
 
-	outf(f, "metadata = \"%s\"", seg->pool_metadata_lv->name);
+	outf(f, "metadata = \"%s\"", seg->metadata_lv->name);
 	outf(f, "pool = \"%s\"", seg_lv(seg, 0)->name);
 	outf(f, "transaction_id = %" PRIu64, seg->transaction_id);
 // FIXME  maybe switch to use  chunksize (as with snapshot ??)
@@ -240,9 +240,9 @@
 		return 1;
 	}
 
-	if (!(metadata_dlid = build_dm_uuid(mem, seg->pool_metadata_lv->lvid.s, NULL))) {
+	if (!(metadata_dlid = build_dm_uuid(mem, seg->metadata_lv->lvid.s, NULL))) {
 		log_error("Failed to build uuid for metadata LV %s.",
-			  seg->pool_metadata_lv->name);
+			  seg->metadata_lv->name);
 		return 0;
 	}
 


