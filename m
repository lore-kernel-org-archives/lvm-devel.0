From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 29 Mar 2011 08:04:52 -0500
Subject: [PATCH 2 of 2] LVM: allow lv_extend of empty layered volumes
Message-ID: <201103291304.p2TD4qWN024143@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-allow-lv_extend-of-empty-layered-volumes.patch

This patch adds the ability to extend 0 length layered LVs.  This
allows us to allocate all images of a mirror (or RAID array) at one
time during create.

The current mirror implementation still requires a separate allocation
for the log, however.

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -2106,29 +2106,90 @@ int lv_add_log_segment(struct alloc_hand
 			      0, status, 0);
 }
 
-static int _lv_extend_mirror(struct alloc_handle *ah,
-			     struct logical_volume *lv,
-			     uint32_t extents, uint32_t first_area,
-			     uint32_t stripes, uint32_t stripe_size)
+static int _lv_insert_empty_layer(struct logical_volume *lv,
+				  const struct segment_type *segtype,
+				  uint32_t region_size,
+				  uint32_t devices)
+{
+	struct logical_volume *sub_lv;
+	uint32_t i;
+	uint64_t status = 0;
+	char *img_name;
+	size_t len;
+	struct lv_segment *mapseg;
+
+	if (lv->le_count || first_seg(lv)) {
+		/*
+		 * This should never happen.  The message is meant
+		 * to help developers.
+		 */
+		log_error("Bad arguments to _lv_insert_empty_layer");
+		return 0;
+	}
+
+	/* FIXME: Mirror specific */
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
+	if (!(img_name = alloca(len)))
+		return_0;
+	if (dm_snprintf(img_name, len, "%s%s", lv->name, "_mimage_%d") < 0)
+		return_0;
+
+	for (i = 0; i < devices; i++) {
+		sub_lv = lv_create_empty(img_name, NULL,
+					 MIRROR_IMAGE, lv->alloc, lv->vg);
+		if (!sub_lv) {
+			log_error("Failed to allocate sub_lv for %s", lv->name);
+			return 0;
+		}
+		if (!set_lv_segment_area_lv(mapseg, i, sub_lv, 0, status))
+			return_0;
+	}
+	dm_list_add(&lv->segments, &mapseg->list);
+
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
@@ -2147,9 +2208,9 @@ static int _lv_extend_mirror(struct allo
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
-	      uint32_t mirrors, uint32_t extents,
-	      struct dm_list *allocatable_pvs,
-	      alloc_policy_t alloc)
+	      uint32_t mirrors, uint32_t region_size,
+	      uint32_t extents,
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc)
 {
 	int r = 1;
 	struct alloc_handle *ah;
@@ -2161,12 +2222,34 @@ int lv_extend(struct logical_volume *lv,
 				    extents, allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (mirrors < 2)
+	if (!segtype_is_mirrored(segtype))
 		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
 				   stripe_size, 0u, 0);
-	else
-		r = _lv_extend_mirror(ah, lv, extents, 0, stripes, stripe_size);
+	else {
+		uint32_t dev_count;
+
+		/*
+		 * When RAID is introduced, all the devices are AREA_LV.
+		 * However, when LVM does 'mirror on stripe' using legacy
+		 * targets, the mirror legs are AREA_LV while the stripes
+		 * underneath are AREA_PV
+		 *
+		if (segtype_is_raid(segtype))
+			dev_count = mirrors * stripes;
+		else
+		*/
+		dev_count = mirrors;
+		if (!lv->le_count &&
+		    !_lv_insert_empty_layer(lv, segtype,
+					    region_size, dev_count)) {
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
@@ -3387,7 +3470,7 @@ static struct logical_volume *_create_vi
 				   ALLOC_INHERIT, vg)))
 		return_NULL;
 
-	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents,
+	if (!lv_extend(lv, segtype, 1, 0, 1, 0, voriginextents,
 		       NULL, ALLOC_INHERIT))
 		return_NULL;
 
@@ -3586,6 +3669,10 @@ int lv_create_single(struct volume_group
 				  "Don't read what you didn't write!");
 			status |= LV_NOTSYNCED;
 		}
+
+		lp->segtype = get_segtype_from_string(cmd, "mirror");
+		if (!lp->segtype)
+			return_0;
 	}
 
 	if (!(lv = lv_create_empty(lp->lv_name ? lp->lv_name : "lvol%d", NULL,
@@ -3609,19 +3696,17 @@ int lv_create_single(struct volume_group
 		dm_list_splice(&lv->tags, &lp->tags);
 
 	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
-		       1, lp->extents, lp->pvh, lp->alloc))
+		       lp->mirrors,
+		       adjusted_mirror_region_size(vg->extent_size,
+						   lv->le_count,
+						   lp->region_size),
+		       lp->extents, lp->pvh, lp->alloc))
 		return_0;
 
 	if (lp->mirrors > 1) {
-		if (!lv_add_mirrors(cmd, lv, lp->mirrors - 1, lp->stripes,
-				    lp->stripe_size,
-				    adjusted_mirror_region_size(
-						vg->extent_size,
-						lv->le_count,
-						lp->region_size),
-				    lp->log_count, lp->pvh, lp->alloc,
-				    MIRROR_BY_LV |
-				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
+		if (!add_mirror_log(cmd, lv, lp->log_count,
+				    first_seg(lv)->region_size,
+				    lp->pvh, lp->alloc)) {
 			stack;
 			goto revert_new_lv;
 		}
Index: LVM2/lib/metadata/metadata-exported.h
===================================================================
--- LVM2.orig/lib/metadata/metadata-exported.h
+++ LVM2/lib/metadata/metadata-exported.h
@@ -500,9 +500,9 @@ int replace_lv_with_error_segment(struct
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
 	      uint32_t stripes, uint32_t stripe_size,
-	      uint32_t mirrors, uint32_t extents,
-	      struct dm_list *allocatable_pvs,
-	      alloc_policy_t alloc);
+	      uint32_t mirrors, uint32_t region_size,
+	      uint32_t extents,
+	      struct dm_list *allocatable_pvs, alloc_policy_t alloc);
 
 /* lv must be part of lv->vg->lvs */
 int lv_remove(struct logical_volume *lv);
Index: LVM2/tools/lvresize.c
===================================================================
--- LVM2.orig/tools/lvresize.c
+++ LVM2/tools/lvresize.c
@@ -670,8 +670,9 @@ static int _lvresize(struct cmd_context 
 			return ECMD_FAILED;
 		}
 	} else if ((lp->extents > lv->le_count) && /* Ensure we extend */
-		   !lv_extend(lv, lp->segtype, lp->stripes,
-			      lp->stripe_size, lp->mirrors,
+		   !lv_extend(lv, lp->segtype,
+			      lp->stripes, lp->stripe_size,
+			      lp->mirrors, first_seg(lv)->region_size,
 			      lp->extents - lv->le_count,
 			      pvh, alloc)) {
 		stack;


