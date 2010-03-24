From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 24 Mar 2010 02:40:00 +0000
Subject: [PATCH 1 of 11] LVM: agk allocation changes
In-Reply-To: <2D4941B1-7C28-4EEA-A7D6-03C0E4613555@redhat.com>
References: <201003120029.o2C0TvC8027865@hydrogen.msp.redhat.com>
	<20100312121941.GA7267@agk-dp.fab.redhat.com>
	<2D4941B1-7C28-4EEA-A7D6-03C0E4613555@redhat.com>
Message-ID: <20100324024000.GN5259@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 12, 2010 at 01:44:52PM -0600, Jon Brassow wrote:
> Still, people can test these patches as long as they don't stress the  
> '--alloc anywhere' cases.

Latest version of this patch.  Still not properly unit tested.

Alasdair


Index: lib/metadata/lv_manip.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/metadata/lv_manip.c,v
retrieving revision 1.212
diff -u -p -r1.212 lv_manip.c
--- lib/metadata/lv_manip.c	23 Mar 2010 22:30:19 -0000	1.212
+++ lib/metadata/lv_manip.c	24 Mar 2010 02:33:51 -0000
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
@@ -999,12 +1006,13 @@ static int _find_parallel_space(struct a
 	struct pv_list *pvl;
 	unsigned already_found_one = 0;
 	unsigned contiguous = 0, cling = 0, preferred_count = 0;
-	unsigned ix;
+	unsigned ix, last_ix;
 	unsigned ix_offset = 0;	/* Offset for non-preferred allocations */
 	unsigned ix_log_offset; /* Offset to start of areas to use for log */
 	unsigned too_small_for_log_count; /* How many too small for log? */
 	uint32_t max_parallel;	/* Maximum extents to allocate */
 	uint32_t next_le;
+	uint32_t required;	/* Extents we're trying to obtain from this area */
 	struct seg_pvs *spvs;
 	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
@@ -1062,6 +1070,9 @@ static int _find_parallel_space(struct a
 			}
 		}
 
+do {
+		/* Safety check to detect when ALLOC_ANYWHERE made no further progress. */
+		last_ix = ix;
 		/*
 		 * Put the smallest area of each PV that is at least the
 		 * size we need into areas array.  If there isn't one
@@ -1089,6 +1100,7 @@ static int _find_parallel_space(struct a
 
 			already_found_one = 0;
 			/* First area in each list is the largest */
+//		retry_pv:
 			dm_list_iterate_items(pva, &pvm->areas) {
 				if (contiguous) {
 					if (prev_lvseg &&
@@ -1114,13 +1126,17 @@ static int _find_parallel_space(struct a
 				}
 
 				/* Is it big enough on its own? */
-				if (pva->count * ah->area_multiple <
+				if (pva->remaining * ah->area_multiple <
 				    max_parallel - *allocated &&
 				    ((!can_split && !ah->log_area_count) ||
 				     (already_found_one &&
 				      !(alloc == ALLOC_ANYWHERE))))
 					goto next_pv;
 
+				/*
+				 * Except with ALLOC_ANYWHERE, replace first area with this 
+				 * one which is smaller but still big enough.
+				 */
 				if (!already_found_one ||
 				    alloc == ALLOC_ANYWHERE) {
 					ix++;
@@ -1133,11 +1149,27 @@ static int _find_parallel_space(struct a
 					*areas_ptr = dm_realloc(*areas_ptr, sizeof(**areas_ptr) * (*areas_size_ptr));
 				}
 				(*areas_ptr)[ix + ix_offset - 1] = pva;
+
+				/* Update amount remaining - effectively splitting an area into two or more parts */
+				if (alloc == ALLOC_ANYWHERE) {
+					required = (max_parallel - *allocated) / ah->area_multiple;
+					if (required >= pva->remaining)
+						pva->remaining = 0;
+					else {
+						pva->remaining -= required;
+						reinsert_reduced_pv_area(pva);
+// ALLOC_ANYWHERE alternative:  don't retry the PV.
+//   At the end of this loop, we have one area per PV.  If we haven't enough, repeat the whole loop (all PVs) taking the next largest from each.
+						// goto retry_pv;  TEMP REMOVAL
+					}
+				}
 			}
 		next_pv:
 			if (ix >= *areas_size_ptr)
 				break;
 		}
+} while(ix < *areas_size_ptr && alloc == ALLOC_ANYWHERE && last_ix != ix);
+
 
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
@@ -1174,7 +1206,6 @@ static int _find_parallel_space(struct a
 		if (ix + ix_offset < ah->area_count +
 		    (log_needs_allocating ? ah->log_area_count +
 					    too_small_for_log_count : 0))
-			/* FIXME With ALLOC_ANYWHERE, need to split areas */
 			break;
 
 		if (!_alloc_parallel_area(ah, max_parallel, *areas_ptr, allocated,
Index: lib/metadata/pv_map.c
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/metadata/pv_map.c,v
retrieving revision 1.35
diff -u -p -r1.35 pv_map.c
--- lib/metadata/pv_map.c	16 Mar 2010 14:37:38 -0000	1.35
+++ lib/metadata/pv_map.c	24 Mar 2010 02:33:51 -0000
@@ -24,19 +24,25 @@
  *
  * FIXME Cope with overlap.
  */
-static void _insert_area(struct dm_list *head, struct pv_area *a)
+static void _insert_area(struct dm_list *head, struct pv_area *a, unsigned reduced)
 {
 	struct pv_area *pva;
-
-	dm_list_iterate_items(pva, head) {
-		if (a->count > pva->count)
+	uint32_t count = reduced ? a->remaining : a->count;
+		
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
Index: lib/metadata/pv_map.h
===================================================================
RCS file: /cvs/lvm2/LVM2/lib/metadata/pv_map.h,v
retrieving revision 1.10
diff -u -p -r1.10 pv_map.h
--- lib/metadata/pv_map.h	3 Nov 2008 22:14:29 -0000	1.10
+++ lib/metadata/pv_map.h	24 Mar 2010 02:33:51 -0000
@@ -31,6 +31,8 @@ struct pv_area {
 	uint32_t start;
 	uint32_t count;
 
+	uint32_t remaining;	/* Number of extents remaining unallocated during allocation number alloc_seqno */
+
 	struct dm_list list;		/* pv_map.areas */
 };
 
@@ -49,6 +51,7 @@ struct dm_list *create_pv_maps(struct dm
 			    struct dm_list *allocatable_pvs);
 
 void consume_pv_area(struct pv_area *area, uint32_t to_go);
+void reinsert_reduced_pv_area(struct pv_area *pva);
 
 uint32_t pv_maps_size(struct dm_list *pvms);
 


