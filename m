From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 11 Mar 2010 18:29:57 -0600
Subject: [PATCH 1 of 11] LVM: agk allocation changes
Message-ID: <201003120029.o2C0TvC8027865@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-agk-allocation-changes.patch

agk's allocation changes.

I'm running into some memory corruption.  I think I've found where
it is but I haven't pinned down how to fix it.
1) In '_allocate', I think areas_size needs to be based on the max
   of 'dm_list_size(pvms)' and 'ah->area_count + ah->log_area_count';
   otherwise, _find_parallel_space won't have enough space to put
   its findings.
2) If you try 'lvcreate -m1 -L 500M -n lv vg --alloc anywhere' on
   two devices, you will corrupt memory.  This is because there
   seems to be no way to get out of the loop in _find_parallel_space
   when retry_pv is called.  'ix' continues to increase and memory
   is written to beyond the bounds allowed in 'areas' until
   pva->remaining reaches zero.


Index: LVM2/lib/metadata/lv_manip.c
===================================================================
--- LVM2.orig/lib/metadata/lv_manip.c
+++ LVM2/lib/metadata/lv_manip.c
@@ -985,6 +985,13 @@ static int _check_contiguous(struct cmd_
 	return 1;
 }
 
+/* FIXME In future if this function is called multiple times with
+ * ALLOC_ANYWHERE after aborted allocation attempts, pv maps will need
+ * re-sorting.
+ * Walk all pv_areas and if remaining != count, set remaining =
+ * count and reinsert_reduced_pv_area.
+ */
+
 /*
  * Choose sets of parallel areas to use, respecting any constraints.
  */
@@ -1005,6 +1012,7 @@ static int _find_parallel_space(struct a
 	unsigned too_small_for_log_count; /* How many too small for log? */
 	uint32_t max_parallel;	/* Maximum extents to allocate */
 	uint32_t next_le;
+	uint32_t required;	/* Extents we're trying to obtain from this area */
 	struct seg_pvs *spvs;
 	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
@@ -1089,6 +1097,7 @@ static int _find_parallel_space(struct a
 
 			already_found_one = 0;
 			/* First area in each list is the largest */
+		retry_pv:
 			dm_list_iterate_items(pva, &pvm->areas) {
 				if (contiguous) {
 					if (prev_lvseg &&
@@ -1114,7 +1123,7 @@ static int _find_parallel_space(struct a
 				}
 
 				/* Is it big enough on its own? */
-				if (pva->count * ah->area_multiple <
+				if (pva->remaining * ah->area_multiple <
 				    max_parallel - *allocated &&
 				    ((!can_split && !ah->log_area_count) ||
 				     (already_found_one &&
@@ -1128,6 +1137,18 @@ static int _find_parallel_space(struct a
 				}
 
 				areas[ix + ix_offset - 1] = pva;
+
+				/* Update amount remaining - effectively splitting an area into two or more parts */
+				if (alloc == ALLOC_ANYWHERE) {
+					required = (max_parallel - *allocated) / ah->area_multiple;
+					if (required >= pva->remaining)
+						pva->remaining = 0;
+					else {
+						pva->remaining -= required;
+						reinsert_reduced_pv_area(pva);
+						goto retry_pv;
+					}
+				}
 			}
 		next_pv:
 			if (ix >= areas_size)
@@ -1169,7 +1190,6 @@ static int _find_parallel_space(struct a
 		if (ix + ix_offset < ah->area_count +
 		    (log_needs_allocating ? ah->log_area_count +
 					    too_small_for_log_count : 0))
-			/* FIXME With ALLOC_ANYWHERE, need to split areas */
 			break;
 
 		if (!_alloc_parallel_area(ah, max_parallel, areas, allocated,
Index: LVM2/lib/metadata/pv_map.c
===================================================================
--- LVM2.orig/lib/metadata/pv_map.c
+++ LVM2/lib/metadata/pv_map.c
@@ -24,19 +24,25 @@
  *
  * FIXME Cope with overlap.
  */
-static void _insert_area(struct dm_list *head, struct pv_area *a)
+static void _insert_area(struct dm_list *head, struct pv_area *a, unsigned reduced)
 {
 	struct pv_area *pva;
+	uint32_t count = reduced ? a->remaining : a->count;
 
-	dm_list_iterate_items(pva, head) {
-		if (a->count > pva->count)
+	dm_list_iterate_items(pva, head)
+		if (count > pva->count)
 			break;
-	}
 
 	dm_list_add(&pva->list, &a->list);
 	a->map->pe_count += a->count;
 }
 
+static void _remove_area(struct pv_area *a)
+{
+	dm_list_del(&a->list);
+	a->map->pe_count -= a->count;
+}
+
 static int _create_single_area(struct dm_pool *mem, struct pv_map *pvm,
 			       uint32_t start, uint32_t length)
 {
@@ -50,7 +56,8 @@ static int _create_single_area(struct dm
 	pva->map = pvm;
 	pva->start = start;
 	pva->count = length;
-	_insert_area(&pvm->areas, pva);
+	pva->remaining = pva->count;
+	_insert_area(&pvm->areas, pva, 0);
 
 	return 1;
 }
@@ -184,8 +191,7 @@ struct dm_list *create_pv_maps(struct dm
 
 void consume_pv_area(struct pv_area *pva, uint32_t to_go)
 {
-	dm_list_del(&pva->list);
-	pva->map->pe_count -= pva->count;
+	_remove_area(pva);
 
 	assert(to_go <= pva->count);
 
@@ -193,10 +199,21 @@ void consume_pv_area(struct pv_area *pva
 		/* split the area */
 		pva->start += to_go;
 		pva->count -= to_go;
-		_insert_area(&pva->map->areas, pva);
+		pva->remaining = pva->count;
+		_insert_area(&pva->map->areas, pva, 0);
 	}
 }
 
+/*
+ * Remove an area from list and reinsert it based on its new smaller size
+ * after a provisional allocation.
+ */
+void reinsert_reduced_pv_area(struct pv_area *pva)
+{
+	_remove_area(pva);
+	_insert_area(&pva->map->areas, pva, 1);
+}
+
 uint32_t pv_maps_size(struct dm_list *pvms)
 {
 	struct pv_map *pvm;
Index: LVM2/lib/metadata/pv_map.h
===================================================================
--- LVM2.orig/lib/metadata/pv_map.h
+++ LVM2/lib/metadata/pv_map.h
@@ -31,6 +31,8 @@ struct pv_area {
 	uint32_t start;
 	uint32_t count;
 
+	uint32_t remaining;	/* Number of extents remaining unallocated */
+
 	struct dm_list list;		/* pv_map.areas */
 };
 
@@ -49,6 +51,7 @@ struct dm_list *create_pv_maps(struct dm
 			    struct dm_list *allocatable_pvs);
 
 void consume_pv_area(struct pv_area *area, uint32_t to_go);
+void reinsert_reduced_pv_area(struct pv_area *pva);
 
 uint32_t pv_maps_size(struct dm_list *pvms);
 


