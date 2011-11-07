From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Nov 2011 11:03:49 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/merg ...
Message-ID: <20111107110349.13183.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-07 11:03:48

Modified files:
	lib/metadata   : lv_manip.c merge.c metadata.h thin_manip.c 
	lib/report     : report.c 
	lib/thin       : thin.c 
	tools          : lvcreate.c 

Log message:
	Thin supports snapshots
	
	Full support for thin snapshots.
	Create and remove is supported.
	
	TODO: lvconvert support is not yes available.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.324&r2=1.325
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.263&r2=1.264
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/thin_manip.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.246&r2=1.247

--- LVM2/lib/metadata/lv_manip.c	2011/11/07 10:58:13	1.324
+++ LVM2/lib/metadata/lv_manip.c	2011/11/07 11:03:47	1.325
@@ -255,9 +255,16 @@
 	dm_list_init(&seg->thin_messages);
 
 	if (thin_pool_lv) {
-		seg->transaction_id = first_seg(thin_pool_lv)->transaction_id;
-		if (!attach_pool_lv(seg, thin_pool_lv))
-			return_NULL;
+		/* If this thin volume, thin snapshot is being created */
+		if (lv_is_thin_volume(thin_pool_lv)) {
+			seg->transaction_id = first_seg(first_seg(thin_pool_lv)->pool_lv)->transaction_id;
+			if (!attach_pool_lv(seg, first_seg(thin_pool_lv)->pool_lv, thin_pool_lv))
+				return_NULL;
+		} else {
+			seg->transaction_id = first_seg(thin_pool_lv)->transaction_id;
+			if (!attach_pool_lv(seg, thin_pool_lv, NULL))
+				return_NULL;
+		}
 	}
 
 	if (log_lv && !attach_mirror_log(seg, log_lv))
@@ -4004,8 +4011,20 @@
 
 	status |= lp->permission | VISIBLE_LV;
 
-	/* FIXME Thin snapshots are different */
-	if (lp->snapshot) {
+	if (lp->snapshot && lp->thin) {
+		if (!(org = find_lv(vg, lp->origin))) {
+			log_error("Couldn't find origin volume '%s'.",
+				  lp->origin);
+			return NULL;
+		}
+
+		if (org->status & LOCKED) {
+			log_error("Snapshots of locked devices are not supported.");
+			return NULL;
+		}
+
+		lp->voriginextents = org->le_count;
+	} else if (lp->snapshot) {
 		if (!activation()) {
 			log_error("Can't create snapshot without using "
 				  "device-mapper kernel driver");
@@ -4074,7 +4093,7 @@
 		return NULL;
 	}
 
-	if (lp->snapshot && (lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
+	if (lp->snapshot && !lp->thin && (lp->extents * vg->extent_size < 2 * lp->chunk_size)) {
 		log_error("Unable to create a snapshot smaller than 2 chunks.");
 		return NULL;
 	}
@@ -4105,7 +4124,7 @@
 	}
 
 	/* The snapshot segment gets created later */
-	if (lp->snapshot &&
+	if (lp->snapshot && !lp->thin &&
 	    !(lp->segtype = get_segtype_from_string(cmd, "striped")))
 		return_NULL;
 
@@ -4173,7 +4192,7 @@
 		       lp->mirrors,
 		       seg_is_thin_pool(lp) ? lp->poolmetadataextents : lp->region_size,
 		       seg_is_thin_volume(lp) ? lp->voriginextents : lp->extents,
-		       seg_is_thin_volume(lp) ? lp->pool : NULL, lp->pvh, lp->alloc))
+		       seg_is_thin_volume(lp) ? (org ? org->name : lp->pool) : NULL, lp->pvh, lp->alloc))
 		return_NULL;
 
 	if (seg_is_thin_pool(lp)) {
@@ -4221,6 +4240,24 @@
 	init_dmeventd_monitor(lp->activation_monitoring);
 
 	if (seg_is_thin(lp)) {
+
+		/* For thin snapshot suspend active thin origin first */
+		if (org && lv_is_active(org)) {
+			if (!suspend_lv(cmd, org)) {
+				log_error("Failed to suspend thin origin %s.",
+					  org->name);
+				goto revert_new_lv;
+			} else if (!resume_lv(cmd, org)) {
+				log_error("Failed to resume thin origin %s.",
+					  org->name);
+				goto revert_new_lv;
+			}
+			/* At this point snapshot is active in kernel thin mda */
+			if (!update_pool_lv(first_seg(org)->pool_lv, 0)) {
+				stack;
+				goto deactivate_and_revert_new_lv;
+			}
+		}
 		if (((lp->activate == CHANGE_AY) ||
 		     (lp->activate == CHANGE_AE) ||
 		     (lp->activate == CHANGE_ALY))) {
@@ -4261,7 +4298,7 @@
 		goto deactivate_and_revert_new_lv;
 	}
 
-	if (lp->snapshot) {
+	if (lp->snapshot && !lp->thin) {
 		/* Reset permission after zeroing */
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
--- LVM2/lib/metadata/merge.c	2011/10/23 16:02:02	1.54
+++ LVM2/lib/metadata/merge.c	2011/11/07 11:03:47	1.55
@@ -373,6 +373,8 @@
 			seg_found++;
 		if (seg->pool_metadata_lv == lv || seg->pool_lv == lv)
 			seg_found++;
+		if (seg_is_thin_volume(seg) && seg->origin == lv)
+			seg_found++;
 		if (!seg_found) {
 			log_error("LV %s is used by LV %s:%" PRIu32 "-%" PRIu32
 				  ", but missing ptr from %s to %s",
--- LVM2/lib/metadata/metadata.h	2011/10/30 22:01:39	1.263
+++ LVM2/lib/metadata/metadata.h	2011/11/07 11:03:47	1.264
@@ -456,7 +456,8 @@
 			    struct logical_volume *pool_metadata_lv);
 int attach_pool_data_lv(struct lv_segment *seg,
 			struct logical_volume *pool_data_lv);
-int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv);
+int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
+		   struct logical_volume *origin_lv);
 int detach_pool_lv(struct lv_segment *seg);
 int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
 			struct logical_volume *lv, uint32_t delete_id,
--- LVM2/lib/metadata/thin_manip.c	2011/11/07 10:59:07	1.23
+++ LVM2/lib/metadata/thin_manip.c	2011/11/07 11:03:47	1.24
@@ -39,10 +39,15 @@
 	return 1;
 }
 
-int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv)
+int attach_pool_lv(struct lv_segment *seg, struct logical_volume *pool_lv,
+		   struct logical_volume *origin)
 {
 	seg->pool_lv = pool_lv;
 	seg->lv->status |= THIN_VOLUME;
+	seg->origin = origin;
+
+	if (origin && !add_seg_to_segs_using_this_lv(origin, seg))
+		return_0;
 
 	return add_seg_to_segs_using_this_lv(pool_lv, seg);
 }
@@ -50,6 +55,7 @@
 int detach_pool_lv(struct lv_segment *seg)
 {
 	struct lv_thin_message *tmsg, *tmp;
+	struct seg_list *sl, *tsl;
 
 	if (!seg->pool_lv || !lv_is_thin_pool(seg->pool_lv)) {
 		log_error(INTERNAL_ERROR "LV %s is not a thin volume",
@@ -78,7 +84,30 @@
 				 NULL, seg->device_id, 0))
 		return_0;
 
-	return remove_seg_from_segs_using_this_lv(seg->pool_lv, seg);
+	if (!remove_seg_from_segs_using_this_lv(seg->pool_lv, seg))
+		return_0;
+
+	if (seg->origin &&
+	    !remove_seg_from_segs_using_this_lv(seg->origin, seg))
+		return_0;
+
+	/* If thin origin, remove it from related thin snapshots */
+	/*
+	 * TODO: map removal of origin as snapshot lvconvert --merge?
+	 * i.e. rename thin snapshot to origin thin origin
+	 */
+	dm_list_iterate_items_safe(sl, tsl, &seg->lv->segs_using_this_lv) {
+		if (!seg_is_thin_volume(sl->seg) ||
+		    (seg->lv != sl->seg->origin))
+			continue;
+
+		if (!remove_seg_from_segs_using_this_lv(seg->lv, sl->seg))
+			return_0;
+		/* Thin snapshot is now regular thin volume */
+		sl->seg->origin = NULL;
+	}
+
+	return 1;
 }
 
 int attach_pool_message(struct lv_segment *seg, dm_thin_message_t type,
--- LVM2/lib/report/report.c	2011/09/09 00:54:49	1.146
+++ LVM2/lib/report/report.c	2011/11/07 11:03:47	1.147
@@ -309,6 +309,9 @@
 	if (lv_is_cow(lv))
 		return _lvname_disp(rh, mem, field, origin_from_cow(lv), private);
 
+	if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
+		return _lvname_disp(rh, mem, field, first_seg(lv)->origin, private);
+
 	dm_report_field_set_value(field, "", NULL);
 	return 1;
 }
--- LVM2/lib/thin/thin.c	2011/11/03 14:52:10	1.30
+++ LVM2/lib/thin/thin.c	2011/11/07 11:03:48	1.31
@@ -317,7 +317,7 @@
 			     struct dm_hash_table *pv_hash __attribute__((unused)))
 {
 	const char *lv_name;
-	struct logical_volume *pool_lv;
+	struct logical_volume *pool_lv, *origin = NULL;
 
 	if (!dm_config_get_str(sn, "thin_pool", &lv_name))
 		return SEG_LOG_ERROR("Thin pool must be a string in");
@@ -325,9 +325,6 @@
 	if (!(pool_lv = find_lv(seg->lv->vg, lv_name)))
 		return SEG_LOG_ERROR("Unknown thin pool %s in", lv_name);
 
-	if (!attach_pool_lv(seg, pool_lv))
-		return_0;
-
 	if (!dm_config_get_uint64(sn, "transaction_id", &seg->transaction_id))
 		return SEG_LOG_ERROR("Could not read transaction_id for");
 
@@ -335,7 +332,7 @@
 		if (!dm_config_get_str(sn, "origin", &lv_name))
 			return SEG_LOG_ERROR("Origin must be a string in");
 
-		if (!(seg->origin = find_lv(seg->lv->vg, lv_name)))
+		if (!(origin = find_lv(seg->lv->vg, lv_name)))
 			return SEG_LOG_ERROR("Unknown origin %s in", lv_name);
 	}
 
@@ -346,6 +343,9 @@
 		return SEG_LOG_ERROR("Unsupported value %u for device_id",
 				     seg->device_id);
 
+	if (!attach_pool_lv(seg, pool_lv, origin))
+		return_0;
+
 	return 1;
 }
 
--- LVM2/tools/lvcreate.c	2011/11/07 11:01:54	1.246
+++ LVM2/tools/lvcreate.c	2011/11/07 11:03:48	1.247
@@ -1013,13 +1013,6 @@
 			    lp.pool, lp.vg_name, lp.snapshot ? " as snapshot of " : "",
 			    lp.snapshot ? lp.origin : "", lp.segtype->name);
 
-	/* FIXME Remove when thin snapshots are supported. */
-	if (lp.thin && lp.snapshot) {
-		log_error("Thin snapshots are not yet supported.");
-		r = ECMD_FAILED;
-		goto_out;
-	}
-
 	if (!lv_create_single(vg, &lp)) {
 		stack;
 		r = ECMD_FAILED;


