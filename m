From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 05 Jul 2011 15:45:14 -0500
Subject: [PATCH 3 of 5] LVM2 update RAID allocation
Message-ID: <1309898714.19763.14.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is to be folded into 'lvm-add-raid-support.patch'.  It is only
separated here to allow those who have already reviewed that patch to see
what I've changed (in this case, changes to the way allocation is done).

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -600,12 +600,21 @@ struct alloc_handle {
 	uint32_t area_multiple;		/* seg->len = area_len * area_multiple */
 	uint32_t log_area_count;	/* Number of parallel logs */
 	uint32_t metadata_area_count;   /* Number of parallel metadata areas */
-	uint32_t log_len;		/* Length of log */
+	uint32_t log_len;		/* Length of log/metadata_area */
 	uint32_t region_size;		/* Mirror region size */
 	uint32_t total_area_len;	/* Total number of parallel extents */
 
 	unsigned maximise_cling;
-	unsigned mirror_logs_separate;	/* Must mirror logs be on separate PVs? */
+	unsigned mirror_logs_separate;	/* Force mirror logs on separate PVs? */
+
+	/*
+	 * RAID devices require a metadata area that accompanies each
+	 * device.  During initial creation, it is best to look for space
+	 * that is new_extents + log_len and then split that between two
+	 * allocated areas when found.  'alloc_and_split_meta' indicates
+	 * that this is the desired dynamic.
+	 */
+	unsigned alloc_and_split_meta;
 
 	const struct config_node *cling_tag_list_cn;
 
@@ -691,7 +700,14 @@ static struct alloc_handle *_alloc_init(
 		area_count = stripes;
 
 	size = sizeof(*ah);
-	alloc_count = area_count + segtype->parity_devs + metadata_area_count;
+	alloc_count = area_count + segtype->parity_devs;
+	if (segtype_is_raid(segtype) && metadata_area_count)
+		/* RAID has a meta area for each device */
+		alloc_count *= 2;
+	else
+		/* mirrors specify their exact log count */
+		alloc_count += metadata_area_count;
+
 	size += sizeof(ah->alloced_areas[0]) * alloc_count;
 
 	if (!(ah = dm_pool_zalloc(mem, size))) {
@@ -722,8 +738,18 @@ static struct alloc_handle *_alloc_init(
 	ah->area_multiple = _calc_area_multiple(segtype, area_count, stripes);
 
 	if (segtype_is_raid(segtype)) {
-		ah->metadata_area_count = area_count;
-		ah->log_len = 1;
+		if (metadata_area_count) {
+			if (metadata_area_count != area_count)
+				log_error(INTERNAL_ERROR
+					  "Bad metadata_area_count");
+			ah->metadata_area_count = area_count;
+			ah->alloc_and_split_meta = 1;
+
+			ah->log_len = 1;
+
+			/* We need 'log_len' extents for each RAID device's metadata_area */
+			ah->new_extents += (ah->log_len * ah->area_count);
+		}
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
@@ -930,9 +956,12 @@ static int _alloc_parallel_area(struct a
 	uint32_t area_len, len;
 	uint32_t s;
 	uint32_t ix_log_skip = 0; /* How many areas to skip in middle of array to reach log areas */
-	uint32_t total_area_count = ah->area_count + alloc_state->log_area_count_still_needed;
+	uint32_t total_area_count;
 	struct alloced_area *aa;
+	struct pv_area *pva;
 
+	total_area_count = ah->area_count + alloc_state->log_area_count_still_needed;
+	total_area_count += ah->parity_count;
 	if (!total_area_count) {
 		log_error(INTERNAL_ERROR "_alloc_parallel_area called without any allocation to do.");
 		return 1;
@@ -941,11 +970,13 @@ static int _alloc_parallel_area(struct a
 	area_len = max_to_allocate / ah->area_multiple;
 
 	/* Reduce area_len to the smallest of the areas */
-	for (s = 0; s < ah->area_count; s++)
+	for (s = 0; s < ah->area_count + ah->parity_count; s++)
 		if (area_len > alloc_state->areas[s].used)
 			area_len = alloc_state->areas[s].used;
 
-	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) * total_area_count))) {
+	len = (ah->alloc_and_split_meta) ? total_area_count * 2 : total_area_count;
+	len *= sizeof(*aa);
+	if (!(aa = dm_pool_alloc(ah->mem, len))) {
 		log_error("alloced_area allocation failed");
 		return 0;
 	}
@@ -957,24 +988,52 @@ static int _alloc_parallel_area(struct a
 	 */
 	len = area_len;
 	for (s = 0; s < total_area_count; s++) {
-		if (s == ah->area_count) {
+		if (s == (ah->area_count + ah->parity_count)) {
 			ix_log_skip = ix_log_offset - ah->area_count;
 			len = ah->log_len;
 		}
 
-		aa[s].pv = alloc_state->areas[s + ix_log_skip].pva->map->pv;
-		aa[s].pe = alloc_state->areas[s + ix_log_skip].pva->start;
-		aa[s].len = len;
+		pva = alloc_state->areas[s + ix_log_skip].pva;
+		if (ah->alloc_and_split_meta) {
+			/*
+			 * The metadata area goes at the front of the allocated
+			 * space for now, but could easily go at the end (or
+			 * middle!).
+			 *
+			 * Even though we split these two from the same
+			 * allocation, we store the images at the beginning
+			 * of the areas array and the metadata at the end.
+			 */
+			s += ah->area_count + ah->parity_count;
+			aa[s].pv = pva->map->pv;
+			aa[s].pe = pva->start;
+			aa[s].len = ah->log_len;
+
+			log_debug("Allocating parallel area %" PRIu32
+				  " on %s start PE %" PRIu32 " length %" PRIu32 ".",
+				  s, pv_dev_name(aa[s].pv), aa[s].pe,
+				  ah->log_len);
+
+			consume_pv_area(pva, ah->log_len);
+			dm_list_add(&ah->alloced_areas[s], &aa[s].list);
+			s -= ah->area_count + ah->parity_count;
+		}
+		aa[s].pv = pva->map->pv;
+		aa[s].pe = pva->start;
+		aa[s].len = (ah->alloc_and_split_meta) ? len - ah->log_len : len;
 
 		log_debug("Allocating parallel area %" PRIu32
 			  " on %s start PE %" PRIu32 " length %" PRIu32 ".",
-			  s, dev_name(aa[s].pv->dev), aa[s].pe, len);
+			  s, pv_dev_name(aa[s].pv), aa[s].pe, aa[s].len);
 
-		consume_pv_area(alloc_state->areas[s + ix_log_skip].pva, len);
+		consume_pv_area(pva, aa[s].len);
 
 		dm_list_add(&ah->alloced_areas[s], &aa[s].list);
 	}
 
+	/* Only need to alloc metadata from the first batch */
+	ah->alloc_and_split_meta = 0;
+
 	ah->total_area_len += area_len;
 
 	alloc_state->allocated += area_len * ah->area_multiple;
@@ -1462,105 +1521,6 @@ static void _clear_areas(struct alloc_st
 }
 
 /*
- * FIXME:  Integrate _find_raid_space with _find_parallel_space...
- * _find_parallel_space is complicated, for now we
- * write our own (albeit simple) routine for raid...  :(
- *
- * We're going to make this really simple.  The conditions are:
- *  - allocation policy can only be contiguous
- *  - we get everything in one go, or we fail
- *
- * Method:
- *  - We find space big enough for the metadata and data for each raid
- *    component (so they can be together)
- *  - We split the large allocation into the two needed for metadata
- *    and data.
- */
-static int _find_raid_space(struct alloc_handle *ah, struct dm_list *pvms)
-{
-	int i;
-	uint32_t s;
-	uint32_t free_pes;
-	struct pv_map *pvm;
-	struct pv_area *pva;
-	uint32_t devices_needed = ah->area_count + ah->parity_count;
-	uint32_t size_per_device = ah->new_extents / ah->area_multiple + ah->log_len;
-	struct alloced_area *aa;
-
-	if (!ah->metadata_area_count) {
-		log_error("_find_raid_space called but !ah->metadata_area_count");
-		return 0;
-	}
-
-	if (ah->metadata_area_count != ah->area_count) {
-		log_error("ah->metadata_area_count != ah->area_count");
-		return 0;
-	}
-
-	free_pes = pv_maps_size(pvms);
-	if (size_per_device * devices_needed > free_pes) {
-		log_error("Insufficient free space: %" PRIu32 " extents needed,"
-			  " but only %" PRIu32 " available",
-			  size_per_device * devices_needed, free_pes);
-		return 0;
-	}
-
-	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) * devices_needed * 2))) {
-		log_error("alloced_area allocation failed");
-		return 0;
-	}
-
-	s = 0;
-	dm_list_iterate_items(pvm, pvms) {
-		log_very_verbose("Checking device %s for %u extents of free space",
-				 dev_name(pvm->pv->dev), size_per_device);
-		if (dm_list_empty(&pvm->areas)) {
-			log_debug("  - no free space");
-			continue;       /* Next PV */
-		}
-		i = 0;
-		dm_list_iterate_items(pva, &pvm->areas) {
-			i++;
-			if (pva->count >= size_per_device) {
-				log_very_verbose("Area %d: %u extents (Match)",
-						 i, pva->count);
-				/*
-				 * Metadata goes at the front for now, but
-				 * could easily go at the end (or middle!).
-				 *
-				 * Even though we split these two from the
-				 * same allocation, we store the images at
-				 * the beginning of the array and the meta
-				 * at the end.
-				 */
-				s += ah->area_count + ah->parity_count;
-				aa[s].pv = pva->map->pv;
-				aa[s].pe = pva->start;
-				aa[s].len = ah->log_len;
-				consume_pv_area(pva, ah->log_len);
-				dm_list_add(&ah->alloced_areas[s], &aa[s].list);
-				s -= ah->area_count + ah->parity_count;
-
-				aa[s].pv = pva->map->pv;
-				aa[s].pe = pva->start;
-				aa[s].len = ah->new_extents / ah->area_multiple;
-				consume_pv_area(pva, ah->new_extents / ah->area_multiple);
-				dm_list_add(&ah->alloced_areas[s], &aa[s].list);
-				s++;
-				devices_needed--;
-				break; /* Now go on to next PV */
-			}
-			log_very_verbose("Area %d: %u extents", i, pva->count);
-		}
-		if (!devices_needed)
-			return 1;
-	}
-	return_0;
-}
-
-
-
-/*
  * Returns 1 regardless of whether any space was found, except on error.
  */
 static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc_parms *alloc_parms,
@@ -1580,6 +1540,7 @@ static int _find_some_parallel_space(str
 	unsigned log_iteration_count = 0; /* extra iteration for logs on data devices */
 	struct alloced_area *aa;
 	uint32_t s;
+	uint32_t devices_needed = ah->area_count + ah->parity_count;
 
 	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
 	if (alloc_parms->flags & (A_CONTIGUOUS | A_CLING) && alloc_parms->prev_lvseg)
@@ -1597,15 +1558,15 @@ static int _find_some_parallel_space(str
 	log_debug("Still need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log areas of %" PRIu32 " extents. "
 		  "(Total %" PRIu32 " extents.)",
 		  (ah->new_extents - alloc_state->allocated) / ah->area_multiple,
-		  ah->area_count, alloc_state->log_area_count_still_needed,
+		  devices_needed, alloc_state->log_area_count_still_needed,
 		  alloc_state->log_area_count_still_needed ? ah->log_len : 0,
-		  (ah->new_extents - alloc_state->allocated) * ah->area_count / ah->area_multiple +
+		  (ah->new_extents - alloc_state->allocated) * devices_needed / ah->area_multiple +
 			alloc_state->log_area_count_still_needed * ah->log_len);
 
 	/* ix holds the number of areas found on other PVs */
 	do {
 		if (log_iteration_count) {
-			log_debug("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, ah->area_count, alloc_state->log_area_count_still_needed);
+			log_debug("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, devices_needed, alloc_state->log_area_count_still_needed);
 		} else if (iteration_count)
 			log_debug("Filled %u out of %u preferred areas so far.", preferred_count, ix_offset);
 
@@ -1648,12 +1609,12 @@ static int _find_some_parallel_space(str
 				 * not enough for the logs.
 				 */
 				if (log_iteration_count) {
-					for (s = ah->area_count; s < ix + ix_offset; s++)
+					for (s = devices_needed; s < ix + ix_offset; s++)
 						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
 							goto next_pv;
 				/* On a second pass, avoid PVs already used in an uncommitted area */
  				} else if (iteration_count)
-					for (s = 0; s < ah->area_count; s++)
+					for (s = 0; s < devices_needed; s++)
 						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
 							goto next_pv;
 			}
@@ -1703,32 +1664,34 @@ static int _find_some_parallel_space(str
 			/* With cling and contiguous we stop if we found a match for *all* the areas */
 			/* FIXME Rename these variables! */
 			if ((alloc_parms->alloc == ALLOC_ANYWHERE &&
-			    ix + ix_offset >= ah->area_count + alloc_state->log_area_count_still_needed) ||
+			    ix + ix_offset >= devices_needed + alloc_state->log_area_count_still_needed) ||
 			    (preferred_count == ix_offset &&
-			     (ix_offset == ah->area_count + alloc_state->log_area_count_still_needed)))
+			     (ix_offset == devices_needed + alloc_state->log_area_count_still_needed))) {
+				log_error("Breaking: preferred_count = %d, ix_offset = %d, devices_needed = %d", preferred_count, ix_offset, devices_needed);
 				break;
+			}
 		}
-	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + alloc_state->log_area_count_still_needed) ||
+	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < devices_needed + alloc_state->log_area_count_still_needed) ||
 		/* With cling_to_alloced, if there were gaps in the preferred areas, have a second iteration */
 		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count &&
 		  (preferred_count < ix_offset || alloc_state->log_area_count_still_needed) &&
 		  (alloc_parms->flags & A_CLING_TO_ALLOCED) && !iteration_count++) ||
 		/* Extra iteration needed to fill log areas on PVs already used? */
 		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count == ix_offset && !ah->mirror_logs_separate &&
-		  (ix + preferred_count >= ah->area_count) && 
-		  (ix + preferred_count < ah->area_count + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
+		  (ix + preferred_count >= devices_needed) &&
+		  (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
 
 	if (preferred_count < ix_offset && !(alloc_parms->flags & A_CLING_TO_ALLOCED))
 		return 1;
 
-	if (ix + preferred_count < ah->area_count + alloc_state->log_area_count_still_needed)
+	if (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed)
 		return 1;
 
 	/* Sort the areas so we allocate from the biggest */
 	if (log_iteration_count) {
-		if (ix > ah->area_count + 1) {
-			log_debug("Sorting %u log areas", ix - ah->area_count);
-			qsort(alloc_state->areas + ah->area_count, ix - ah->area_count, sizeof(*alloc_state->areas),
+		if (ix > devices_needed + 1) {
+			log_debug("Sorting %u log areas", ix - devices_needed);
+			qsort(alloc_state->areas + devices_needed, ix - devices_needed, sizeof(*alloc_state->areas),
 			      _comp_area);
 		}
 	} else if (ix > 1) {
@@ -1739,7 +1702,7 @@ static int _find_some_parallel_space(str
 
 	/* If there are gaps in our preferred areas, fill then from the sorted part of the array */
 	if (preferred_count && preferred_count != ix_offset) {
-		for (s = 0; s < ah->area_count; s++)
+		for (s = 0; s < devices_needed; s++)
 			if (!alloc_state->areas[s].pva) {
 				alloc_state->areas[s].pva = alloc_state->areas[ix_offset].pva;
 				alloc_state->areas[s].used = alloc_state->areas[ix_offset].used;
@@ -1764,7 +1727,7 @@ static int _find_some_parallel_space(str
 		ix_log_offset = ix_offset + ix - too_small_for_log_count - ah->log_area_count;
 	}
 
-	if (ix + ix_offset < ah->area_count +
+	if (ix + ix_offset < devices_needed +
 	    (alloc_state->log_area_count_still_needed ? alloc_state->log_area_count_still_needed +
 				    too_small_for_log_count : 0))
 		return 1;
@@ -1919,18 +1882,6 @@ static int _allocate(struct alloc_handle
 	}
 
 	/*
-	 * FIXME:
-	 * We are calling an simplified alternate allocation scheme for
-	 * RAID.  We can only detect if RAID is wanted by the
-	 * metadata_area_count... and that is only needed on create.  This
-	 * means we also won't be able to extend a RAID device for now.
-	 */
-	if (ah->metadata_area_count) {
-		r = _find_raid_space(ah, pvms);
-		goto out;
-	}
-
-	/*
 	 * cling includes implicit cling_by_tags
 	 * but it does nothing unless the lvm.conf setting is present.
 	 */
@@ -2483,7 +2434,7 @@ int lv_extend(struct logical_volume *lv,
 		return lv_add_virtual_segment(lv, 0u, extents, segtype);
 
 	if (segtype_is_raid(segtype) && !lv->le_count)
-		allocate_raid_logs = dev_count;
+		allocate_raid_logs = mirrors * stripes;
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    allocate_raid_logs, region_size,



