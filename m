From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 6 Apr 2011 21:32:22 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20110406213222.10912.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-04-06 21:32:21

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	tools          : lvresize.c 

Log message:
	This patch adds the ability to extend 0 length layered LVs.  This
	allows us to allocate all images of a mirror (or RAID array) at one
	time during create.
	
	The current mirror implementation still requires a separate allocation
	for the log, however.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.254&r2=1.255
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.188&r2=1.189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/lib/metadata/lv_manip.c	2011/03/29 20:19:04	1.254
+++ LVM2/lib/metadata/lv_manip.c	2011/04/06 21:32:20	1.255
@@ -2106,29 +2106,87 @@
 			      0, status, 0);
 }
 
-static int _lv_extend_mirror(struct alloc_handle *ah,
-			     struct logical_volume *lv,
-			     uint32_t extents, uint32_t first_area,
-			     uint32_t stripes, uint32_t stripe_size)
+static int _lv_insert_empty_sublvs(struct logical_volume *lv,
+				   const struct segment_type *segtype,
+				   uint32_t region_size,
+				   uint32_t devices)
+{
+	struct logical_volume *sub_lv;
+	uint32_t i;
+	uint64_t status = 0;
+	char *img_name;
+	size_t len;
+	struct lv_segment *mapseg;
+
+	if (lv->le_count || first_seg(lv)) {
+		log_error(INTERNAL_ERROR
+			  "Non-empty LV passed to _lv_insert_empty_sublv");
+		return 0;
+	}
+
+	if (!segtype_is_mirrored(segtype))
+		return_0;
+	lv->status |= MIRRORED;
+
+	/*
+	 * First, create our top-level segment for our top-level LV
+	 */
+	if (!(mapseg = alloc_lv_segment(lv->vg->cmd->mem, segtype,
+					lv, 0, 0, lv->status, 0, NULL,
+					devices, 0, 0, region_size, 0, NULL))) {
+		log_error("Failed to create mapping segment for %s", lv->name);
+		return 0;
+	}
+
+	/*
+	 * Next, create all of our sub_lv's and link them in.
+	 */
+	len = strlen(lv->name) + 32;
+	if (!(img_name = dm_pool_alloc(lv->vg->cmd->mem, len)))
+		return_0;
+	if (dm_snprintf(img_name, len, "%s%s", lv->name, "_mimage_%d") < 0)
+		return_0;
+
+	for (i = 0; i < devices; i++) {
+		sub_lv = lv_create_empty(img_name, NULL,
+					 MIRROR_IMAGE, lv->alloc, lv->vg);
+		if (!sub_lv)
+			return_0;
+		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, status))
+			return_0;
+	}
+	dm_list_add(&lv->segments, &mapseg->list);
+
+	dm_pool_free(lv->vg->cmd->mem, img_name);
+	return 1;
+}
+
+static int _lv_extend_layered_lv(struct alloc_handle *ah,
+				 struct logical_volume *lv,
+				 uint32_t extents, uint32_t first_area,
+				 uint32_t stripes, uint32_t stripe_size)
 {
+	struct logical_volume *sub_lv;
 	struct lv_segment *seg;
 	uint32_t m, s;
 
 	seg = first_seg(lv);
 	for (m = first_area, s = 0; s < seg->area_count; s++) {
 		if (is_temporary_mirror_layer(seg_lv(seg, s))) {
-			if (!_lv_extend_mirror(ah, seg_lv(seg, s), extents, m, stripes, stripe_size))
+			if (!_lv_extend_layered_lv(ah, seg_lv(seg, s), extents,
+						   m, stripes, stripe_size))
 				return_0;
 			m += lv_mirror_count(seg_lv(seg, s));
 			continue;
 		}
 
-		if (!lv_add_segment(ah, m, stripes, seg_lv(seg, s),
+		sub_lv = seg_lv(seg, s);
+		if (!lv_add_segment(ah, m, stripes, sub_lv,
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
-				    stripe_size, 0, 0)) {
-			log_error("Aborting. Failed to extend %s.",
-				  seg_lv(seg, s)->name);
+				    stripe_size, sub_lv->status, 0)) {
+			log_error("Aborting. Failed to extend %s in %s.",
+				  sub_lv->name, lv->name);
 			return 0;
 		}
 		m += stripes;
@@ -2147,28 +2205,35 @@
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
-	      uint32_t mirrors, uint32_t extents,
-	      struct physical_volume *mirrored_pv __attribute__((unused)),
-	      uint32_t mirrored_pe __attribute__((unused)),
-	      uint64_t status, struct dm_list *allocatable_pvs,
-	      alloc_policy_t alloc)
+	      uint32_t mirrors, uint32_t region_size,
+	      uint32_t extents,
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	int r = 1;
 	struct alloc_handle *ah;
 
 	if (segtype_is_virtual(segtype))
-		return lv_add_virtual_segment(lv, status, extents, segtype);
+		return lv_add_virtual_segment(lv, 0u, extents, segtype);
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0, 0,
 				    extents, allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (mirrors < 2)
+	if (!segtype_is_mirrored(segtype))
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
-				   stripe_size, status, 0);
-	else
-		r = _lv_extend_mirror(ah, lv, extents, 0, stripes, stripe_size);
+				   stripe_size, 0u, 0);
+	else {
+		if (!lv->le_count &&
+		    !_lv_insert_empty_sublvs(lv, segtype,
+					     region_size, mirrors)) {
+			log_error("Failed to insert layer for %s", lv->name);
+			alloc_destroy(ah);
+			return 0;
+		}
 
+		r = _lv_extend_layered_lv(ah, lv, extents, 0,
+					  stripes, stripe_size);
+	}
 	alloc_destroy(ah);
 	return r;
 }
@@ -3389,7 +3454,7 @@
 				   ALLOC_INHERIT, vg)))
 		return_NULL;
 
-	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
+	if (!lv_extend(lv, segtype, 1, 0, 1, 0, voriginextents,
 		       NULL, ALLOC_INHERIT))
 		return_NULL;
 
@@ -3588,6 +3653,10 @@
 				  "Don't read what you didn't write!");
 			status |= LV_NOTSYNCED;
 		}
+
+		lp->segtype = get_segtype_from_string(cmd, "mirror");
+		if (!lp->segtype)
+			return_0;
 	}
 
 	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
@@ -3611,19 +3680,17 @@
 		dm_list_splice(&lv->tags, &lp->tags);
 
 	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       1, lp->extents, NULL, 0u, 0u, lp->pvh, lp->alloc))
+		       lp->mirrors,
+		       adjusted_mirror_region_size(vg->extent_size,
+						   lp->extents,
+						   lp->region_size),
+		       lp->extents, lp->pvh, lp->alloc))
 		return_0;
 
-	if (lp->mirrors > 1) {
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
-				    lp->stripe_size,
-				    adjusted_mirror_region_size(
-						vg->extent_size,
-						lv->le_count,
-						lp->region_size),
-				    lp->log_count, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV |
-				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
+	if ((lp->mirrors > 1) && lp->log_count) {
+		if (!add_mirror_log(cmd, lv, lp->log_count,
+				    first_seg(lv)->region_size,
+				    lp->pvh, lp->alloc)) {
 			stack;
 			goto revert_new_lv;
 		}
--- LVM2/lib/metadata/metadata-exported.h	2011/03/29 12:51:57	1.188
+++ LVM2/lib/metadata/metadata-exported.h	2011/04/06 21:32:20	1.189
@@ -500,10 +500,9 @@
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
-	      uint32_t mirrors, uint32_t extents,
-	      struct physical_volume *mirrored_pv, uint32_t mirrored_pe,
-	      uint64_t status, struct dm_list *allocatable_pvs,
-	      alloc_policy_t alloc);
+	      uint32_t mirrors, uint32_t region_size,
+	      uint32_t extents,
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc);
 
 /* lv must be part of lv->vg->lvs */
 int lv_remove(struct logical_volume *lv);
--- LVM2/lib/metadata/mirror.c	2011/03/29 12:51:57	1.146
+++ LVM2/lib/metadata/mirror.c	2011/04/06 21:32:20	1.147
@@ -1899,8 +1899,9 @@
 	}
 
 	/* check sync status */
-	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
-	    (sync_percent == PERCENT_100))
+	if (mirror_in_sync() ||
+	    (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
+	     (sync_percent == PERCENT_100)))
 		in_sync = 1;
 	else
 		in_sync = 0;
--- LVM2/tools/lvresize.c	2011/03/02 16:56:07	1.129
+++ LVM2/tools/lvresize.c	2011/04/06 21:32:21	1.130
@@ -670,10 +670,11 @@
 			return ECMD_FAILED;
 		}
 	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
-		   !lv_extend(lv, lp->segtype, lp->stripes,
-			      lp->stripe_size, lp->mirrors,
+		   !lv_extend(lv, lp->segtype,
+			      lp->stripes, lp->stripe_size,
+			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count,
-			      NULL, 0u, 0u, pvh, alloc)) {
+			      pvh, alloc)) {
 		stack;
 		return ECMD_FAILED;
 	}


