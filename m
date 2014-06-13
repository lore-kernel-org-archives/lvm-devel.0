From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 13 Jun 2014 00:16:03 -0500
Subject: [POC PATCH] atomic pvmove
Message-ID: <1402636563.28598.14.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch still needs some polish, but I want to know I am heading in
the right direction.  I'm open to any suggestions on variable/function
names and what-not.  I'm also quite confused as to how to preserve
PVMOVE in seg->status, so I don't get the annoying error at the end of a
pvmove signaling the status isn't right.

Basically, rather than mirroring the segments directly, I add an LV
mirror layer whose newly allocated image contains a one-to-one segment
agreement to the primary image.  This required a special function,
lv_add_segmented_mirror_image, since the normal behavior is simply to
allocate 1 segment that might contain the necessary size - regardless of
the number of segments in the original.  The segments are important, as
they are the portions of distinct LVs which are being moved.  (Thus, it
is important that the segments also not be merged as would normally
happen.)

 brassow

Index: lvm2/lib/metadata/lv_manip.c
===================================================================
--- lvm2.orig/lib/metadata/lv_manip.c
+++ lvm2/lib/metadata/lv_manip.c
@@ -2712,6 +2712,99 @@ static struct lv_segment *_convert_seg_t
 /*
  * Add new areas to mirrored segments
  */
+int lv_add_segmented_mirror_image(struct alloc_handle *ah,
+				  struct logical_volume *lv, uint32_t le,
+				  uint32_t region_size)
+{
+	char *image_name;
+	struct alloced_area *aa;
+	struct lv_segment *seg, *new_seg;
+	uint32_t current_le = le;
+	uint32_t s;
+	struct segment_type *segtype;
+	struct logical_volume *orig_lv, *copy_lv;
+
+	if (!(lv->status & PVMOVE)) {
+		log_error(INTERNAL_ERROR
+			  "Non-pvmove LV, %s, passed as argument", lv->name);
+		return 0;
+	}
+
+	if (seg_type(first_seg(lv), 0) != AREA_PV) {
+		log_error(INTERNAL_ERROR
+			  "Bad segment type for first segment area");
+		return 0;
+	}
+
+	if (!insert_layer_for_lv(lv->vg->cmd, lv, PVMOVE, "_mimage_0")) {
+		log_error("Failed to build pvmove LV-type mirror, %s",
+			  lv->name);
+		return 0;
+	}
+	orig_lv = seg_lv(first_seg(lv), 0);
+	if (!(image_name = dm_pool_strdup(lv->vg->vgmem, orig_lv->name)))
+		return_0;
+	image_name[strlen(image_name) - 1] = '1';
+
+	if (!(copy_lv = lv_create_empty(image_name, NULL,
+					orig_lv->status,
+					ALLOC_INHERIT, lv->vg)))
+		return_0;
+
+	if (!lv_add_mirror_lvs(lv, &copy_lv, 1, MIRROR_IMAGE, region_size))
+		return_0;
+
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+		return_0;
+
+	dm_list_iterate_items(aa, &ah->alloced_areas[0]) {
+		if (!(seg = find_seg_by_le(orig_lv, current_le))) {
+			log_error("Failed to find segment for %s extent %"
+				  PRIu32, lv->name, current_le);
+			return 0;
+		}
+
+		/* Allocator assures aa[0].len <= seg->area_len */
+		if (aa[0].len < seg->area_len) {
+			log_error("Splitting segment on %s", orig_lv->name);
+			if (!lv_split_segment(orig_lv, seg->le + aa[0].len)) {
+				log_error("Failed to split segment at %s "
+					  "extent %" PRIu32, lv->name, le);
+				return 0;
+			}
+		}
+
+		if (!(new_seg = alloc_lv_segment(segtype, copy_lv,
+						 seg->le, seg->len, PVMOVE, 0,
+						 NULL, NULL, 1, seg->len,
+						 0, 0, 0, NULL)))
+			return_0;
+
+		for (s = 0; s < ah->area_count; s++) {
+			if (!set_lv_segment_area_pv(new_seg, s,
+						    aa[s].pv, aa[s].pe))
+				return_0;
+		}
+
+		dm_list_add(&copy_lv->segments, &new_seg->list);
+
+		current_le += seg->area_len;
+		copy_lv->le_count += seg->area_len;
+	}
+	lv->status |= MIRRORED;
+
+	/* FIXME: add log */
+
+	if (lv->vg->fid->fmt->ops->lv_setup &&
+	    !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
+		return_0;
+
+	return 1;
+}
+
+/*
+ * Add new areas to mirrored segments
+ */
 int lv_add_mirror_areas(struct alloc_handle *ah,
 			struct logical_volume *lv, uint32_t le,
 			uint32_t region_size)
@@ -5121,7 +5214,8 @@ int remove_layers_for_segments(struct cm
 					  "%s:%" PRIu32 " status: 0x%" PRIx64 "/0x%" PRIx64,
 					  layer_lv->name, lseg->le,
 					  lseg->status, status_mask);
-				return 0;
+//				return 0;
+				lseg->status |= (status_mask & PVMOVE);
 			}
 			if (lseg->le != seg_le(seg, s) ||
 			    lseg->area_len != seg->area_len) {
Index: lvm2/tools/pvmove.c
===================================================================
--- lvm2.orig/tools/pvmove.c
+++ lvm2/tools/pvmove.c
@@ -486,7 +486,9 @@ static struct logical_volume *_set_up_pv
 	}
 
 	if (!lv_add_mirrors(cmd, lv_mirr, 1, 1, 0, 0, log_count,
-			    allocatable_pvs, alloc, MIRROR_BY_SEG)) {
+			    allocatable_pvs, alloc,
+			    (arg_count(cmd, atomic_ARG)) ?
+			    MIRROR_BY_SEGMENTED_LV : MIRROR_BY_SEG)) {
 		log_error("Failed to convert pvmove LV to mirrored");
 		return_NULL;
 	}
@@ -515,15 +517,54 @@ static int _activate_lv(struct cmd_conte
 	return r;
 }
 
+static int _is_pvmove_image_removable(struct logical_volume *mimage_lv,
+				      void *baton)
+{
+	uint32_t s = *((uint32_t *)baton);
+	struct lv_segment *mirror_seg;
+
+	if (!(mirror_seg = get_only_segment_using_this_lv(mimage_lv))) {
+		log_error(INTERNAL_ERROR
+			  "%s is not a proper mirror image",
+			  mimage_lv->name);
+		return 0;
+	}
+
+	if (seg_type(mirror_seg, 0) != AREA_LV) {
+		log_error(INTERNAL_ERROR
+			  "%s is not a pvmove mirror of LV-type",
+			  mirror_seg->lv->name);
+		return 0;
+	}
+
+	if (s > mirror_seg->area_count) {
+		log_error(INTERNAL_ERROR
+			  "Invalid segment number");
+		return 0;
+	}
+
+	if (seg_lv(mirror_seg, s) == mimage_lv)
+		return 1;
+
+	return 0;
+}
+
 static int _detach_pvmove_mirror(struct cmd_context *cmd,
 				 struct logical_volume *lv_mirr)
 {
+	uint32_t s = 0;
 	struct dm_list lvs_completed;
 	struct lv_list *lvl;
 
 	/* Update metadata to remove mirror segments and break dependencies */
 	dm_list_init(&lvs_completed);
-	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0, NULL, NULL, PVMOVE) ||
+
+	if (arg_is_set(cmd, abort_ARG) &&
+	    (seg_type(first_seg(lv_mirr), 0) == AREA_LV))
+		s = 1; /* remove the second mirror leg */
+
+	if (!lv_remove_mirrors(cmd, lv_mirr, 1, 0,
+			       _is_pvmove_image_removable, &s, PVMOVE) ||
 	    !remove_layers_for_segments_all(cmd, lv_mirr, PVMOVE,
 					    &lvs_completed)) {
 		return 0;
Index: lvm2/lib/metadata/mirror.c
===================================================================
--- lvm2.orig/lib/metadata/mirror.c
+++ lvm2/lib/metadata/mirror.c
@@ -949,6 +949,7 @@ static int _remove_mirror_images(struct
 		mirrored_seg = first_seg(lv);
 		if (remove_log && !detached_log_lv)
 			detached_log_lv = detach_mirror_log(mirrored_seg);
+		first_seg(lv)->status |= (lv->status & PVMOVE);
 	} else if (new_area_count == 0) {
 		log_very_verbose("All mimages of %s are gone", lv->name);
 
@@ -1557,7 +1558,9 @@ struct logical_volume *find_pvmove_lv(st
 
 		/* Check segment origins point to pvname */
 		dm_list_iterate_items(seg, &lv->segments) {
-			if (seg_type(seg, 0) != AREA_PV)
+			if (seg_type(seg, 0) == AREA_LV) /* Atomic pvmove */
+				seg = first_seg(seg_lv(seg, 0));
+			if (seg_type(seg, 0) != AREA_PV) /* Segment pvmove */
 				continue;
 			if (seg_dev(seg, 0) != dev)
 				continue;
@@ -1652,13 +1655,14 @@ int fixup_imported_mirrors(struct volume
 	return 1;
 }
 
-/*
- * Add mirrors to "linear" or "mirror" segments
- */
-int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
-			    uint32_t mirrors, uint32_t region_size,
-			    struct dm_list *allocatable_pvs, alloc_policy_t alloc)
+static int _add_mirrors_that_preserve_segments(struct logical_volume *lv,
+					       uint32_t flags,
+					       uint32_t mirrors,
+					       uint32_t region_size,
+					       struct dm_list *allocatable_pvs,
+					       alloc_policy_t alloc)
 {
+	struct cmd_context *cmd = lv->vg->cmd;
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
@@ -1682,16 +1686,38 @@ int add_mirrors_to_segments(struct cmd_c
 		return 0;
 	}
 
-	if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
-		log_error("Failed to add mirror areas to %s", lv->name);
+	if (flags & MIRROR_BY_SEG) {
+		if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
+			log_error("Failed to add mirror areas to %s", lv->name);
+			r = 0;
+		}
+	} else if (flags & MIRROR_BY_SEGMENTED_LV) {
+		if (!lv_add_segmented_mirror_image(ah, lv, 0,
+						   adjusted_region_size)) {
+			log_error("Failed to add mirror areas to %s", lv->name);
+			r = 0;
+		}
+	} else {
+		log_error(INTERNAL_ERROR "Unknown mirror flag");
 		r = 0;
 	}
-
 	alloc_destroy(ah);
 	return r;
 }
 
 /*
+ * Add mirrors to "linear" or "mirror" segments
+ */
+int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
+			    uint32_t mirrors, uint32_t region_size,
+			    struct dm_list *allocatable_pvs, alloc_policy_t alloc)
+{
+	return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEG,
+						   mirrors, region_size,
+						   allocatable_pvs, alloc);
+}
+
+/*
  * Convert mirror log
  *
  * FIXME: Can't handle segment-by-segment mirror (like pvmove)
@@ -2112,8 +2138,19 @@ int lv_add_mirrors(struct cmd_context *c
 			return 0;
 		}
 
-		return add_mirrors_to_segments(cmd, lv, mirrors,
-					       region_size, pvs, alloc);
+		return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEG,
+							   mirrors, region_size,
+							   pvs, alloc);
+	} else if (flags & MIRROR_BY_SEGMENTED_LV) {
+		if (stripes > 1) {
+			log_error("Striped-mirroring is not supported on "
+				  "segment-by-segment mirroring");
+			return 0;
+		}
+
+		return _add_mirrors_that_preserve_segments(lv, MIRROR_BY_SEGMENTED_LV,
+							   mirrors, region_size,
+							   pvs, alloc);
 	} else if (flags & MIRROR_BY_LV) {
 		if (!mirrors)
 			return add_mirror_log(cmd, lv, log_count,
Index: lvm2/lib/metadata/merge.c
===================================================================
--- lvm2.orig/lib/metadata/merge.c
+++ lvm2/lib/metadata/merge.c
@@ -38,11 +38,16 @@ static int _merge(struct lv_segment *fir
 int lv_merge_segments(struct logical_volume *lv)
 {
 	struct dm_list *segh, *t;
-	struct lv_segment *current, *prev = NULL;
+	struct lv_segment *seg, *current, *prev = NULL;
 
 	if (lv->status & LOCKED || lv->status & PVMOVE)
 		return 1;
 
+	if ((lv->status & MIRROR_IMAGE) &&
+	    (seg = get_only_segment_using_this_lv(lv)) &&
+	    (seg->lv->status & LOCKED || seg->lv->status & PVMOVE))
+		return 1;
+
 	dm_list_iterate_safe(segh, t, &lv->segments) {
 		current = dm_list_item(segh, struct lv_segment);
 
Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -133,6 +133,10 @@
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
 #define MIRROR_BY_LV		0x00000002U	/* mirror using whole mimage LVs */
+#define MIRROR_BY_SEGMENTED_LV	0x00000004U	/* mirror using whole mimage
+						 * LVs, but preserve the
+						 * segment layout templated by
+						 * the primary mimage */
 #define MIRROR_SKIP_INIT_SYNC	0x00000010U	/* skip initial sync */
 
 /* vg_read and vg_read_for_update flags */
Index: lvm2/tools/args.h
===================================================================
--- lvm2.orig/tools/args.h
+++ lvm2/tools/args.h
@@ -17,6 +17,7 @@
  * Put all long args that don't have a corresponding short option first.
  */
 /* *INDENT-OFF* */
+arg(atomic_ARG, '\0', "atomic", NULL, 0)
 arg(version_ARG, '\0', "version", NULL, 0)
 arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
Index: lvm2/tools/commands.h
===================================================================
--- lvm2.orig/tools/commands.h
+++ lvm2/tools/commands.h
@@ -761,6 +761,7 @@ xx(pvmove,
    0,
    "pvmove " "\n"
    "\t[--abort]\n"
+   "\t[--atomic]\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -777,7 +778,7 @@ xx(pvmove,
    "\tSourcePhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]}\n"
    "\t[DestinationPhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]...]\n",
 
-   abort_ARG, alloc_ARG, autobackup_ARG, background_ARG,
+   abort_ARG, atomic_ARG, alloc_ARG, autobackup_ARG, background_ARG,
    interval_ARG, name_ARG, noudevsync_ARG, test_ARG)
 
 xx(pvremove,
Index: lvm2/lib/metadata/lv_alloc.h
===================================================================
--- lvm2.orig/lib/metadata/lv_alloc.h
+++ lvm2/lib/metadata/lv_alloc.h
@@ -68,6 +68,9 @@ int lv_add_segment(struct alloc_handle *
 int lv_add_mirror_areas(struct alloc_handle *ah,
 			struct logical_volume *lv, uint32_t le,
 			uint32_t region_size);
+int lv_add_segmented_mirror_image(struct alloc_handle *ah,
+				  struct logical_volume *lv, uint32_t le,
+				  uint32_t region_size);
 int lv_add_mirror_lvs(struct logical_volume *lv,
 		      struct logical_volume **sub_lvs,
 		      uint32_t num_extra_areas,



