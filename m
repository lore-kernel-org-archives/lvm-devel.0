From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 8 Oct 2009 16:18:36 -0500
Subject: [PATCH 2 of 10] LVM: make log_area a list
Message-ID: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-make-log_area-a-list.patch

The 'alloc_handle' structure only has space for one log_area.
We change that to a list to allow an arbitrary number of
log areas.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -515,7 +515,7 @@ struct alloc_handle {
 
 	struct dm_list *parallel_areas;	/* PVs to avoid */
 
-	struct alloced_area log_area;	/* Extent used for log */
+	struct dm_list log_areas;	/* Extents used for logs */
 	struct dm_list alloced_areas[0];	/* Lists of areas in each stripe */
 };
 
@@ -582,6 +582,7 @@ static struct alloc_handle *_alloc_init(
 	ah->alloc = alloc;
 	ah->area_multiple = calc_area_multiple(segtype, area_count);
 
+	dm_list_init(&ah->log_areas);
 	for (s = 0; s < ah->area_count; s++)
 		dm_list_init(&ah->alloced_areas[s]);
 
@@ -763,10 +764,11 @@ static int _alloc_parallel_area(struct a
 		consume_pv_area(areas[s], area_len);
 
 	if (log_area) {
-		ah->log_area.pv = log_area->map->pv;
-		ah->log_area.pe = log_area->start;
-		ah->log_area.len = log_len;
-		consume_pv_area(log_area, ah->log_area.len);
+		aa[s].pv = log_area->map->pv;
+		aa[s].pe = log_area->start;
+		aa[s].len = log_len;
+		dm_list_add(&ah->log_areas, &aa[s].list);
+		consume_pv_area(log_area, log_len);
 	}
 
 	*ix += area_len * ah->area_multiple;
@@ -983,6 +985,7 @@ static int _find_parallel_space(struct a
 				struct lv_segment *prev_lvseg,
 				uint32_t *allocated, uint32_t needed)
 {
+	int skip = 0;
 	struct pv_map *pvm;
 	struct pv_area *pva;
 	struct pv_list *pvl;
@@ -999,6 +1002,7 @@ static int _find_parallel_space(struct a
 	uint32_t log_len;
 	struct pv_area *log_area;
 	unsigned log_needs_allocating;
+	struct alloced_area *aa;
 
 	/* Is there enough total space? */
 	free_pes = pv_maps_size(pvms);
@@ -1061,10 +1065,14 @@ static int _find_parallel_space(struct a
 				continue;	/* Next PV */
 
 			if (alloc != ALLOC_ANYWHERE) {
-				/* Don't allocate onto the log pv */
-				if (ah->log_count &&
-				    pvm->pv == ah->log_area.pv)
-					continue;	/* Next PV */
+				/* Don't allocate onto the log pvs */
+				dm_list_iterate_items(aa, &ah->log_areas)
+					if (pvm->pv == aa->pv)
+						skip = 1;
+				if (skip) {
+					skip = 0;
+					continue;
+				}
 
 				/* Avoid PVs used by existing parallel areas */
 				if (parallel_pvs)
@@ -1125,8 +1133,9 @@ static int _find_parallel_space(struct a
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
 
-		log_needs_allocating = (ah->log_count && !ah->log_area.len) ?
-				       1 : 0;
+		log_needs_allocating = 0;
+		if (ah->log_count && dm_list_empty(&ah->log_areas))
+			log_needs_allocating = 1;
 
 		if (ix + ix_offset < ah->area_count +
 		   (log_needs_allocating ? ah->log_count : 0))
@@ -1199,6 +1208,7 @@ static int _allocate(struct alloc_handle
 	struct dm_list *pvms;
 	uint32_t areas_size;
 	alloc_policy_t alloc;
+	struct alloced_area *aa;
 
 	if (allocated >= new_extents && !ah->log_count) {
 		log_error("_allocate called with no work to do!");
@@ -1264,12 +1274,13 @@ static int _allocate(struct alloc_handle
 		goto out;
 	}
 
-	if (ah->log_count && !ah->log_area.len) {
-		log_error("Insufficient extents for log allocation "
-			  "for logical volume %s.",
-			  lv ? lv->name : "");
-		goto out;
-	}
+	dm_list_iterate_items(aa, &ah->log_areas)
+		if (ah->log_count && !aa->len) {
+			log_error("Insufficient extents for log allocation "
+				  "for logical volume %s.",
+				  lv ? lv->name : "");
+			goto out;
+		}
 
 	r = 1;
 
@@ -1545,10 +1556,21 @@ int lv_add_mirror_lvs(struct logical_vol
 
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
@@ -1558,19 +1580,21 @@ int lv_add_log_segment(struct alloc_hand
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


