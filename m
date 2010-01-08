From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 8 Jan 2010 22:32:36 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20100108223236.28920.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-08 22:32:35

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	man            : lvconvert.8.in lvcreate.8.in 
	tools          : commands.h lvconvert.c lvcreate.c 

Log message:
	Add the new mirror log type "redundant".  The options are now:
	--mirrorlog core: in-memory log
	--mirrorlog disk: persistent log
	--mirrorlog redundant: redundant persistent log
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1376&r2=1.1377
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvconvert.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.212&r2=1.213

--- LVM2/WHATS_NEW	2010/01/08 22:28:54	1.1376
+++ LVM2/WHATS_NEW	2010/01/08 22:32:35	1.1377
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Add redundant mirror log option.
   Add capability to split off and keep mirror legs to lvconvert.
   Change background polldaemon's process name to "(lvm2)".
   Allow vgremove of a VG with PVs missing.
--- LVM2/lib/metadata/lv_manip.c	2010/01/05 21:07:31	1.191
+++ LVM2/lib/metadata/lv_manip.c	2010/01/08 22:32:35	1.192
@@ -515,7 +515,7 @@
 
 	struct dm_list *parallel_areas;	/* PVs to avoid */
 
-	struct alloced_area log_area;	/* Extent used for log */
+	struct dm_list log_areas;	/* Extents used for logs */
 	struct dm_list alloced_areas[0];	/* Lists of areas in each stripe */
 };
 
@@ -582,6 +582,7 @@
 	ah->alloc = alloc;
 	ah->area_multiple = calc_area_multiple(segtype, area_count);
 
+	dm_list_init(&ah->log_areas);
 	for (s = 0; s < ah->area_count; s++)
 		dm_list_init(&ah->alloced_areas[s]);
 
@@ -644,8 +645,7 @@
 				  uint32_t stripe_size,
 				  const struct segment_type *segtype,
 				  struct alloced_area *aa,
-				  uint32_t region_size,
-				  struct logical_volume *log_lv __attribute((unused)))
+				  uint32_t region_size)
 {
 	uint32_t s, extents, area_multiple;
 	struct lv_segment *seg;
@@ -685,15 +685,14 @@
 				   uint64_t status,
 				   uint32_t stripe_size,
 				   const struct segment_type *segtype,
-				   uint32_t region_size,
-				   struct logical_volume *log_lv)
+				   uint32_t region_size)
 {
 	struct alloced_area *aa;
 
 	dm_list_iterate_items(aa, &alloced_areas[0]) {
 		if (!_setup_alloced_segment(lv, status, area_count,
 					    stripe_size, segtype, aa,
-					    region_size, log_lv))
+					    region_size))
 			return_0;
 	}
 
@@ -729,11 +728,11 @@
  */
 static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t needed,
 				struct pv_area **areas,
-				uint32_t *ix, struct pv_area *log_area,
+				uint32_t *ix, struct pv_area **log_areas,
 				uint32_t log_len)
 {
 	uint32_t area_len, remaining;
-	uint32_t s;
+	uint32_t i,s;
 	struct alloced_area *aa;
 
 	remaining = needed - *ix;
@@ -744,8 +743,8 @@
 		if (area_len > areas[s]->count)
 			area_len = areas[s]->count;
 
-	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) *
-			      (ah->area_count + (log_area ? 1 : 0))))) {
+	s = sizeof(*aa) * (ah->area_count + ah->log_count);
+	if (!(aa = dm_pool_alloc(ah->mem, s))) {
 		log_error("alloced_area allocation failed");
 		return 0;
 	}
@@ -762,11 +761,14 @@
 	for (s = 0; s < ah->area_count; s++)
 		consume_pv_area(areas[s], area_len);
 
-	if (log_area) {
-		ah->log_area.pv = log_area->map->pv;
-		ah->log_area.pe = log_area->start;
-		ah->log_area.len = log_len;
-		consume_pv_area(log_area, ah->log_area.len);
+	for (i = 0, s = ah->area_count;
+	     (s < ah->area_count + ah->log_count);
+	     s++, i++) {
+		aa[s].pv = log_areas[i]->map->pv;
+		aa[s].pe = log_areas[i]->start;
+		aa[s].len = log_len;
+		dm_list_add(&ah->log_areas, &aa[s].list);
+		consume_pv_area(log_areas[i], log_len);
 	}
 
 	*ix += area_len * ah->area_multiple;
@@ -983,6 +985,7 @@
 				struct lv_segment *prev_lvseg,
 				uint32_t *allocated, uint32_t needed)
 {
+	int i, j, skip = 0;
 	struct pv_map *pvm;
 	struct pv_area *pva;
 	struct pv_list *pvl;
@@ -997,8 +1000,9 @@
 	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
 	uint32_t log_len;
-	struct pv_area *log_area;
+	struct pv_area **log_areas;
 	unsigned log_needs_allocating;
+	struct alloced_area *aa;
 
 	/* Is there enough total space? */
 	free_pes = pv_maps_size(pvms);
@@ -1061,10 +1065,16 @@
 				continue;	/* Next PV */
 
 			if (alloc != ALLOC_ANYWHERE) {
-				/* Don't allocate onto the log pv */
-				if (ah->log_count &&
-				    pvm->pv == ah->log_area.pv)
-					continue;	/* Next PV */
+				/* Don't allocate onto the log pvs */
+				dm_list_iterate_items(aa, &ah->log_areas)
+					if (pvm->pv == aa->pv) {
+						skip = 1;
+						break;
+					}
+				if (skip) {
+					skip = 0;
+					continue;
+				}
 
 				/* Avoid PVs used by existing parallel areas */
 				if (parallel_pvs)
@@ -1125,11 +1135,17 @@
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
 
-		log_needs_allocating = (ah->log_count && !ah->log_area.len) ?
-				       1 : 0;
+		log_needs_allocating = 0;
+		if (ah->log_count && dm_list_empty(&ah->log_areas))
+			log_needs_allocating = 1;
 
+		/*
+		 * Note:  If we allow logs on the same devices as mirror
+		 * images, then that shouldn't factor into the equation.
+		 */
 		if (ix + ix_offset < ah->area_count +
-		   (log_needs_allocating ? ah->log_count : 0))
+		    ((log_needs_allocating && (alloc != ALLOC_ANYWHERE)) ?
+		     ah->log_count : 0))
 			break;
 
 		/* sort the areas so we allocate from the biggest */
@@ -1148,8 +1164,12 @@
 
 		if (!log_needs_allocating) {
 			log_len = 0;
-			log_area = NULL;
+			log_areas = NULL;
 		} else {
+			log_areas = dm_pool_alloc(ah->mem,
+						  sizeof(struct pv_area) *
+						  ah->log_count);
+
 			log_len = mirror_log_extents(ah->log_region_size,
 			    pv_pe_size((*areas)->map->pv),
 			    (max_parallel - *allocated) / ah->area_multiple);
@@ -1160,18 +1180,25 @@
 				  too_small_for_log_count))->count < log_len)
 				too_small_for_log_count++;
 
-			log_area = *(areas + ix_offset + ix - 1 -
-				     too_small_for_log_count);
+			i = ah->log_count - 1;
+			j = ix_offset + ix - 1 - too_small_for_log_count;
+			for (; (i >= 0) && (j >= 0); i--) {
+				log_areas[i] = *(areas + j);
+
+				/* Advance to next PV */
+				for (; ((j >= 0) &&
+					(log_areas[i]->map->pv == (*(areas + j))->map->pv)); j--);
+			}
 		}
 
 		if (ix + ix_offset < ah->area_count +
-		    (log_needs_allocating ? ah->log_count +
-					    too_small_for_log_count : 0))
+		    ((log_needs_allocating  && (alloc != ALLOC_ANYWHERE)) ?
+		     ah->log_count + too_small_for_log_count : 0))
 			/* FIXME With ALLOC_ANYWHERE, need to split areas */
 			break;
 
 		if (!_alloc_parallel_area(ah, max_parallel, areas, allocated,
-					  log_area, log_len))
+					  log_areas, log_len))
 			return_0;
 
 	} while (!contiguous && *allocated != needed && can_split);
@@ -1199,6 +1226,7 @@
 	struct dm_list *pvms;
 	uint32_t areas_size;
 	alloc_policy_t alloc;
+	struct alloced_area *aa;
 
 	if (allocated >= new_extents && !ah->log_count) {
 		log_error("_allocate called with no work to do!");
@@ -1264,11 +1292,14 @@
 		goto out;
 	}
 
-	if (ah->log_count && !ah->log_area.len) {
-		log_error("Insufficient extents for log allocation "
-			  "for logical volume %s.",
-			  lv ? lv->name : "");
-		goto out;
+	if (ah->log_count) {
+		dm_list_iterate_items(aa, &ah->log_areas)
+			if (!aa->len) {
+				log_error("Insufficient extents for log "
+					  "allocation for logical volume %s.",
+					  lv ? lv->name : "");
+				goto out;
+			}
 	}
 
 	r = 1;
@@ -1359,6 +1390,18 @@
 		   uint32_t region_size,
 		   struct logical_volume *log_lv)
 {
+	int i;
+	struct dm_list *aa_list;
+
+	/*
+	 * We don't actually use the 'log_lv' parameter for anything more
+	 * than just figuring out that this allocation is for a log device
+	 * It'd be nice to change the arguments type, but the function is
+	 * exported.
+	 */
+	aa_list = (log_lv) ? &ah->log_areas :
+		&ah->alloced_areas[first_area];
+
 	if (!segtype) {
 		log_error("Missing segtype in lv_add_segment().");
 		return 0;
@@ -1369,10 +1412,8 @@
 		return 0;
 	}
 
-	if (!_setup_alloced_segments(lv, &ah->alloced_areas[first_area],
-				     num_areas, status,
-				     stripe_size, segtype,
-				     region_size, log_lv))
+	if (!_setup_alloced_segments(lv, aa_list, num_areas, status,
+				     stripe_size, segtype, region_size))
 		return_0;
 
 	if ((segtype->flags & SEG_CAN_SPLIT) && !lv_merge_segments(lv)) {
@@ -1545,10 +1586,21 @@
 
 /*
  * Turn an empty LV into a mirror log.
+ *
+ * Only for the addition of the first, linear log.
  */
 int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
 {
 	struct lv_segment *seg;
+	struct alloced_area *log_area;
+
+	dm_list_iterate_items(log_area, &ah->log_areas)
+		break;
+
+	if (!log_area)
+		return 0;
+
+	dm_list_del(&log_area->list);
 
 	if (dm_list_size(&log_lv->segments)) {
 		log_error("Log segments can only be added to an empty LV");
@@ -1558,19 +1610,21 @@
 	if (!(seg = alloc_lv_segment(log_lv->vg->cmd->mem,
 				     get_segtype_from_string(log_lv->vg->cmd,
 							     "striped"),
-				     log_lv, 0, ah->log_area.len, MIRROR_LOG,
-				     0, NULL, 1, ah->log_area.len, 0, 0, 0))) {
+				     log_lv, 0, log_area->len, MIRROR_LOG,
+				     0, NULL, 1, log_area->len, 0, 0, 0))) {
 		log_error("Couldn't allocate new mirror log segment.");
 		return 0;
 	}
 
-	if (!set_lv_segment_area_pv(seg, 0, ah->log_area.pv, ah->log_area.pe))
+	if (!set_lv_segment_area_pv(seg, 0, log_area->pv, log_area->pe))
 		return_0;
 
 	dm_list_add(&log_lv->segments, &seg->list);
-	log_lv->le_count += ah->log_area.len;
+	log_lv->le_count += log_area->len;
 	log_lv->size += (uint64_t) log_lv->le_count * log_lv->vg->extent_size;
 
+	dm_pool_free(ah->mem, log_area);
+
 	if (log_lv->vg->fid->fmt->ops->lv_setup &&
 	    !log_lv->vg->fid->fmt->ops->lv_setup(log_lv->vg->fid, log_lv))
 		return_0;
@@ -3055,7 +3109,7 @@
 						vg->extent_size,
 						lv->le_count,
 						lp->region_size),
-				    lp->corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    lp->log_count, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV |
 				    (lp->nosync ? MIRROR_SKIP_INIT_SYNC : 0))) {
 			stack;
--- LVM2/lib/metadata/metadata-exported.h	2009/11/24 22:55:56	1.124
+++ LVM2/lib/metadata/metadata-exported.h	2010/01/08 22:32:35	1.125
@@ -527,7 +527,7 @@
 	int zero; /* all */
 	int major; /* all */
 	int minor; /* all */
-	int corelog; /* mirror */
+	int log_count; /* mirror */
 	int nosync; /* mirror */
 
 	char *origin; /* snap */
@@ -652,6 +652,8 @@
 		   uint32_t mirrors, uint32_t stripes,
 		   uint32_t region_size, uint32_t log_count,
 		   struct dm_list *pvs, alloc_policy_t alloc, uint32_t flags);
+int lv_split_mirror_images(struct logical_volume *lv, const char *split_lv_name,
+			   uint32_t split_count, struct dm_list *removable_pvs);
 int lv_remove_mirrors(struct cmd_context *cmd, struct logical_volume *lv,
 		      uint32_t mirrors, uint32_t log_count,
 		      struct dm_list *pvs, uint64_t status_mask);
--- LVM2/lib/metadata/mirror.c	2010/01/08 22:00:31	1.105
+++ LVM2/lib/metadata/mirror.c	2010/01/08 22:32:35	1.106
@@ -1171,7 +1171,8 @@
 static int _create_mimage_lvs(struct alloc_handle *ah,
 			      uint32_t num_mirrors,
 			      struct logical_volume *lv,
-			      struct logical_volume **img_lvs)
+			      struct logical_volume **img_lvs,
+			      int for_log)
 {
 	uint32_t m;
 	char *img_name;
@@ -1202,7 +1203,7 @@
 		if (!lv_add_segment(ah, m, 1, img_lvs[m],
 				    get_segtype_from_string(lv->vg->cmd,
 							    "striped"),
-				    0, 0, 0, NULL)) {
+				    0, 0, 0, for_log ? lv : NULL)) {
 			log_error("Aborting. Failed to add mirror image segment "
 				  "to %s. Remove new LV and retry.",
 				  img_lvs[m]->name);
@@ -1547,11 +1548,51 @@
 	return log_lv;
 }
 
+/*
+ * Returns: 1 on success, 0 on error
+ */
+static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
+			struct logical_volume *lv,
+			uint32_t mirrors, uint32_t region_size, int for_log)
+{
+	struct logical_volume **img_lvs;
+
+	/*
+	 * insert a mirror layer
+	 */
+	if (dm_list_size(&lv->segments) != 1 ||
+	    seg_type(first_seg(lv), 0) != AREA_LV)
+		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
+			return 0;
+
+	/*
+	 * create mirror image LVs
+	 */
+	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
+		log_error("img_lvs allocation failed. "
+			  "Remove new LV and retry.");
+		return 0;
+	}
+
+	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs, for_log))
+		return 0;
+
+	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
+			       MIRROR_IMAGE | (lv->status & LOCKED),
+			       region_size)) {
+		log_error("Aborting. Failed to add mirror segment. "
+			  "Remove new LV and retry.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
 						 struct alloc_handle *ah,
 						 struct logical_volume *lv,
 						 uint32_t log_count,
-						 uint32_t region_size __attribute((unused)),
+						 uint32_t region_size,
 						 alloc_policy_t alloc,
 						 int in_sync)
 {
@@ -1563,11 +1604,6 @@
 
 	init_mirror_in_sync(in_sync);
 
-	if (log_count != 1) {
-		log_error("log_count != 1 is not supported.");
-		return NULL;
-	}
-
 	/* Mirror log name is lv_name + suffix, determined as the following:
 	 *   1. suffix is:
 	 *        o "_mlog" for the original mirror LV.
@@ -1600,6 +1636,12 @@
 		return NULL;
 	}
 
+	if ((log_count > 1) &&
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, region_size, 1)) {
+		log_error("Failed to form mirrored log.");
+		return NULL;
+	}
+
 	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
 		log_error("Failed to initialise mirror log.");
 		return NULL;
@@ -1630,12 +1672,6 @@
 	struct lvinfo info;
 	int r = 0;
 
-	/* Unimplemented features */
-	if (log_count > 1) {
-		log_error("log_count > 1 is not supported");
-		return 0;
-	}
-
 	if (dm_list_size(&lv->segments) != 1) {
 		log_error("Multiple-segment mirror is not supported");
 		return 0;
@@ -1707,7 +1743,6 @@
 	struct alloc_handle *ah;
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
-	struct logical_volume **img_lvs;
 	struct logical_volume *log_lv = NULL;
 
 	if (stripes > 1) {
@@ -1747,34 +1782,9 @@
 	   So from here on, if failure occurs, the log must be explicitly
 	   removed and the updated vg metadata should be committed. */
 
-	/*
-	 * insert a mirror layer
-	 */
-	if (dm_list_size(&lv->segments) != 1 ||
-	    seg_type(first_seg(lv), 0) != AREA_LV)
-		if (!insert_layer_for_lv(cmd, lv, 0, "_mimage_%d"))
-			goto out_remove_log;
-
-	/*
-	 * create mirror image LVs
-	 */
-	if (!(img_lvs = alloca(sizeof(*img_lvs) * mirrors))) {
-		log_error("img_lvs allocation failed. "
-			  "Remove new LV and retry.");
-		goto out_remove_log;
-	}
-
-	if (!_create_mimage_lvs(ah, mirrors, lv, img_lvs))
+	if (!_form_mirror(cmd, ah, lv, mirrors, region_size, 0))
 		goto out_remove_log;
 
-	if (!lv_add_mirror_lvs(lv, img_lvs, mirrors,
-			       MIRROR_IMAGE | (lv->status & LOCKED),
-			       region_size)) {
-		log_error("Aborting. Failed to add mirror segment. "
-			  "Remove new LV and retry.");
-		goto out_remove_images;
-	}
-
 	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))
 		stack;
 
--- LVM2/man/lvconvert.8.in	2010/01/08 22:00:31	1.10
+++ LVM2/man/lvconvert.8.in	2010/01/08 22:32:35	1.11
@@ -3,7 +3,7 @@
 lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-\-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
+\-m|\-\-mirrors Mirrors [\-\-mirrorlog {disk|core|redundant}] [\-\-corelog] [\-R|\-\-regionsize MirrorLogRegionSize]
 [\-A|\-\-alloc AllocationPolicy]
 [\-b|\-\-background] [\-f|\-\-force] [\-i|\-\-interval Seconds]
 [\-h|\-?|\-\-help]
@@ -71,6 +71,7 @@
 Core may be useful for short-lived mirrors: It means the mirror is
 regenerated by copying the data from the first device again every
 time the device is activated - perhaps, for example, after every reboot.
+Using "redundant" will create a persistent log that is itself mirrored.
 .TP
 .I \-\-corelog
 The optional argument "--corelog" is the same as specifying "--mirrorlog core".
--- LVM2/man/lvcreate.8.in	2009/10/26 13:41:13	1.12
+++ LVM2/man/lvcreate.8.in	2010/01/08 22:32:35	1.13
@@ -11,7 +11,7 @@
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-M|\-\-persistent y|n] [\-\-minor minor]
-[\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
+[\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core|redundant}] [\-\-corelog]
 [\-R|\-\-regionsize MirrorLogRegionSize]]
 [\-n|\-\-name LogicalVolumeName]
 [\-p|\-\-permission r|rw] [\-r|\-\-readahead ReadAheadSectors|auto|none]
@@ -107,9 +107,10 @@
 The optional argument --mirrorlog specifies the type of log to be used.
 The default is disk, which is persistent and requires
 a small amount of storage space, usually on a separate device from the
-data being mirrored. Using core means the mirror is regenerated
+data being mirrored.  Using core means the mirror is regenerated
 by copying the data from the first device again each time the
-device is activated, for example, after every reboot.
+device is activated, for example, after every reboot.  Using "redundant"
+will create a persistent log that is itself mirrored.
 
 The optional argument --corelog is equivalent to --mirrorlog core.
 
--- LVM2/tools/commands.h	2010/01/08 22:00:31	1.137
+++ LVM2/tools/commands.h	2010/01/08 22:32:35	1.138
@@ -96,7 +96,7 @@
    "Change logical volume layout",
    0,
    "lvconvert "
-   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|redundant}|--corelog}]]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -145,7 +145,7 @@
    "\t{-l|--extents LogicalExtentsNumber |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|redundant}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
--- LVM2/tools/lvconvert.c	2010/01/08 22:00:31	1.105
+++ LVM2/tools/lvconvert.c	2010/01/08 22:32:35	1.106
@@ -550,18 +550,18 @@
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
-			       int corelog)
+			       int log_count)
 {
 	struct logical_volume *original_lv = _original_lv(lv);
-	if (_using_corelog(lv) && !corelog) {
-		if (!add_mirror_log(cmd, original_lv, 1,
+	if (_using_corelog(lv) && log_count) {
+		if (!add_mirror_log(cmd, original_lv, log_count,
 				    adjusted_mirror_region_size(
 					lv->vg->extent_size,
 					lv->le_count,
 					lp->region_size),
 				    lp->pvh, lp->alloc))
 			return_0;
-	} else if (!_using_corelog(lv) && corelog) {
+	} else if (!_using_corelog(lv) && !log_count) {
 		if (!remove_mirror_log(cmd, original_lv,
 				       lp->pv_count ? lp->pvh : NULL))
 			return_0;
@@ -613,7 +613,7 @@
 	struct lv_segment *seg;
 	uint32_t existing_mirrors;
 	const char *mirrorlog;
-	unsigned corelog = 0;
+	unsigned log_count = 0;
 	int r = 0;
 	struct logical_volume *log_lv, *layer_lv;
 	int failed_mirrors = 0, failed_log = 0;
@@ -671,7 +671,7 @@
 	if (existing_mirrors && lp->mirrors &&
 	    (lp->mirrors != existing_mirrors) &&
 	    !arg_count(cmd, mirrorlog_ARG) && !arg_count(cmd, corelog_ARG)) {
-		corelog = first_seg(lv)->log_lv ? 0 : 1;
+		log_count = lv_mirror_count(first_seg(lv)->log_lv);
 	}
 
 	if (repair) {
@@ -692,8 +692,10 @@
 			return_0;
 		lp->pvh = lp->failed_pvs = failed_pvs;
 		log_lv=first_seg(lv)->log_lv;
-		if (!log_lv || log_lv->status & PARTIAL_LV)
-			failed_log = corelog = 1;
+		if (!log_lv || log_lv->status & PARTIAL_LV) {
+			failed_log = 1;
+			log_count = 0;
+		}
 	} else {
 		/*
 		 * Did the user try to subtract more legs than available?
@@ -707,20 +709,29 @@
 		/*
 		 * Adjust log type
 		 */
+		/*
+		 * This param used to be 'corelog' and was initialized to '0'.
+		 * We initially set to '1' here so as not to screw the logic.
+		 */
+		log_count = 1;
 		if (arg_count(cmd, corelog_ARG))
-			corelog = 1;
+			log_count = 0;
 
 		mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-					  corelog ? "core" : DEFAULT_MIRRORLOG);
-		if (!strcmp("disk", mirrorlog)) {
-			if (corelog) {
-				log_error("--mirrorlog disk and --corelog "
-					  "are incompatible");
-				return 0;
-			}
-			corelog = 0;
-		} else if (!strcmp("core", mirrorlog))
-			corelog = 1;
+					  !log_count ? "core" : DEFAULT_MIRRORLOG);
+
+		if (strcmp("core", mirrorlog) && !log_count) {
+			log_error("--mirrorlog disk and --corelog "
+				  "are incompatible");
+			return 0;
+		}
+
+		if (!strcmp("redundant", mirrorlog))
+			log_count = 2;
+		else if (!strcmp("disk", mirrorlog))
+			log_count = 1;
+		else if (!strcmp("core", mirrorlog))
+			log_count = 0;
 		else {
 			log_error("Unknown mirrorlog type: %s", mirrorlog);
 			return 0;
@@ -779,12 +790,12 @@
 						    remove_pvs))
 				return 0;
 		} else if (!lv_remove_mirrors(cmd, lv, existing_mirrors - lp->mirrors,
-					      (corelog || lp->mirrors == 1) ? 1U : 0U,
+					      (!log_count || lp->mirrors == 1) ? 1U : 0U,
 					      remove_pvs, 0))
 			return_0;
 
 		if (lp->mirrors > 1 &&
-		    !_lv_update_log_type(cmd, lp, lv, corelog))
+		    !_lv_update_log_type(cmd, lp, lv, log_count))
 			return_0;
 	} else if (!(lv->status & MIRRORED)) {
 		/*
@@ -811,7 +822,7 @@
 						lv->vg->extent_size,
 						lv->le_count,
 						lp->region_size),
-				    corelog ? 0U : 1U, lp->pvh, lp->alloc,
+				    log_count, lp->pvh, lp->alloc,
 				    MIRROR_BY_LV)) {
 			stack;
 			return failure_code;
@@ -843,7 +854,7 @@
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.
 		 */
-		if (!_lv_update_log_type(cmd, lp, lv, corelog)) {
+		if (!_lv_update_log_type(cmd, lp, lv, log_count)) {
 			stack;
 			return failure_code;
 		}
@@ -881,8 +892,8 @@
 	}
 
 	if (lp->mirrors == existing_mirrors) {
-		if (_using_corelog(lv) != corelog) {
-			if (!_lv_update_log_type(cmd, lp, lv, corelog)) {
+		if (_using_corelog(lv) != !log_count) {
+			if (!_lv_update_log_type(cmd, lp, lv, log_count)) {
 				stack;
 				return failure_code;
 			}
@@ -922,8 +933,10 @@
 
 	if (failed_log || failed_mirrors) {
 		lp->pvh = old_pvh;
-		if (failed_log && replace_log)
-			failed_log = corelog = 0;
+		if (failed_log && replace_log) {
+			failed_log = 0;
+			log_count = 1;
+		}
 		if (replace_mirrors)
 			lp->mirrors += failed_mirrors;
 		failed_mirrors = 0;
--- LVM2/tools/lvcreate.c	2009/12/03 01:47:34	1.212
+++ LVM2/tools/lvcreate.c	2010/01/08 22:32:35	1.213
@@ -323,21 +323,29 @@
 	int region_size;
 	const char *mirrorlog;
 
+	/*
+	 * This param used to be 'corelog' and was initialized to '0'.
+	 * We initially set to '1' here so as not to screw the logic.
+	 */
+	lp->log_count = 1;
 	if (arg_count(cmd, corelog_ARG))
-		lp->corelog = 1;
+		lp->log_count = 0;
 
 	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
-				  lp->corelog ? "core" : DEFAULT_MIRRORLOG);
+				  !lp->log_count ? "core" : DEFAULT_MIRRORLOG);
 
-	if (!strcmp("disk", mirrorlog)) {
-		if (lp->corelog) {
-			log_error("--mirrorlog disk and --corelog "
-				  "are incompatible");
-			return 0;
-		}
-		lp->corelog = 0;
-	} else if (!strcmp("core", mirrorlog))
-		lp->corelog = 1;
+	if (strcmp("core", mirrorlog) && !lp->log_count) {
+		log_error("--mirrorlog disk and --corelog "
+			  "are incompatible");
+		return 0;
+	}
+
+	if (!strcmp("redundant", mirrorlog))
+		lp->log_count = 2;
+	else if (!strcmp("disk", mirrorlog))
+		lp->log_count = 1;
+	else if (!strcmp("core", mirrorlog))
+		lp->log_count = 0;
 	else {
 		log_error("Unknown mirrorlog type: %s", mirrorlog);
 		return 0;


