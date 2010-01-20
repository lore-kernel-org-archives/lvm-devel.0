From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 19 Jan 2010 20:21:46 -0600
Subject: [PATCH 3 of 10] LVM: build log_area list
Message-ID: <201001200221.o0K2LkVh023966@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-build-log_area-list.patch

Now that we have change the allocation handle structure to be
able to store a list of log areas, fill them in and utilize
them based on the 'log_count' parameter.  (log_count will
be generalized in subsequent patches, but it is still just
'1' or '0' for now... meaning nothing has changed at this
point.)

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -730,11 +730,11 @@ static uint32_t mirror_log_extents(uint3
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
@@ -745,8 +745,8 @@ static int _alloc_parallel_area(struct a
 		if (area_len > areas[s]->count)
 			area_len = areas[s]->count;
 
-	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) *
-			      (ah->area_count + (log_area ? 1 : 0))))) {
+	s = sizeof(*aa) * (ah->area_count + ah->log_count);
+	if (!(aa = dm_pool_alloc(ah->mem, s))) {
 		log_error("alloced_area allocation failed");
 		return 0;
 	}
@@ -763,12 +763,14 @@ static int _alloc_parallel_area(struct a
 	for (s = 0; s < ah->area_count; s++)
 		consume_pv_area(areas[s], area_len);
 
-	if (log_area) {
-		aa[s].pv = log_area->map->pv;
-		aa[s].pe = log_area->start;
+	for (i = 0, s = ah->area_count;
+	     (s < ah->area_count + ah->log_count);
+	     s++, i++) {
+		aa[s].pv = log_areas[i]->map->pv;
+		aa[s].pe = log_areas[i]->start;
 		aa[s].len = log_len;
 		dm_list_add(&ah->log_areas, &aa[s].list);
-		consume_pv_area(log_area, log_len);
+		consume_pv_area(log_areas[i], log_len);
 	}
 
 	*ix += area_len * ah->area_multiple;
@@ -985,6 +987,7 @@ static int _find_parallel_space(struct a
 				struct lv_segment *prev_lvseg,
 				uint32_t *allocated, uint32_t needed)
 {
+	int i, j;
 	struct pv_map *pvm;
 	struct pv_area *pva;
 	struct pv_list *pvl;
@@ -999,7 +1002,7 @@ static int _find_parallel_space(struct a
 	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
 	uint32_t log_len;
-	struct pv_area *log_area;
+	struct pv_area **log_areas;
 	unsigned log_needs_allocating;
 	struct alloced_area *aa;
 
@@ -1130,8 +1133,13 @@ static int _find_parallel_space(struct a
 		if (ah->log_count && dm_list_empty(&ah->log_areas))
 			log_needs_allocating = 1;
 
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
@@ -1150,8 +1158,12 @@ static int _find_parallel_space(struct a
 
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
@@ -1162,18 +1174,25 @@ static int _find_parallel_space(struct a
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


