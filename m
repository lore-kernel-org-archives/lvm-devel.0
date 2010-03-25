From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 21:19:27 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20100325211927.29856.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 21:19:27

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c pv_map.c pv_map.h 

Log message:
	Allow ALLOC_ANYWHERE to split contiguous areas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1481&r2=1.1482
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.215&r2=1.216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2010/03/25 18:22:39	1.1481
+++ LVM2/WHATS_NEW	2010/03/25 21:19:26	1.1482
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Allow ALLOC_ANYWHERE to split contiguous areas.
   Use INTERNAL_ERROR for internal errors throughout tree.
   Add some assertions to allocation code.
   Introduce pv_area_used into allocation algorithm and add debug messages.
--- LVM2/lib/metadata/lv_manip.c	2010/03/25 18:16:55	1.215
+++ LVM2/lib/metadata/lv_manip.c	2010/03/25 21:19:27	1.216
@@ -1018,7 +1018,7 @@
 	struct pv_list *pvl;
 	unsigned already_found_one = 0;
 	unsigned contiguous = 0, cling = 0, preferred_count = 0;
-	unsigned ix;
+	unsigned ix, last_ix;
 	unsigned ix_offset = 0;	/* Offset for non-preferred allocations */
 	unsigned ix_log_offset; /* Offset to start of areas to use for log */
 	unsigned too_small_for_log_count; /* How many too small for log? */
@@ -1085,99 +1085,125 @@
 		log_needs_allocating = (ah->log_area_count &&
 					dm_list_empty(&ah->alloced_areas[ah->area_count])) ?  1 : 0;
 
-		/*
-		 * Put the smallest area of each PV that is at least the
-		 * size we need into areas array.  If there isn't one
-		 * that fits completely and we're allowed more than one
-		 * LV segment, then take the largest remaining instead.
-		 */
-		dm_list_iterate_items(pvm, pvms) {
-			if (dm_list_empty(&pvm->areas))
-				continue;	/* Next PV */
-
-			if (alloc != ALLOC_ANYWHERE) {
-				/* Don't allocate onto the log pv */
-				if (ah->log_area_count)
-					dm_list_iterate_items(aa, &ah->alloced_areas[ah->area_count])
-						for (s = 0; s < ah->log_area_count; s++)
-							if (!aa[s].pv)
+		do {
+			/*
+			 * Provide for escape from the loop if no progress is made.
+			 * This should not happen: ALLOC_ANYWHERE should be able to use
+			 * all available space. (If there aren't enough extents, the code
+			 * should not reach this point.)
+			 */
+			last_ix = ix;
+
+			/*
+			 * Put the smallest area of each PV that is at least the
+			 * size we need into areas array.  If there isn't one
+			 * that fits completely and we're allowed more than one
+			 * LV segment, then take the largest remaining instead.
+			 */
+			dm_list_iterate_items(pvm, pvms) {
+				if (dm_list_empty(&pvm->areas))
+					continue;	/* Next PV */
+
+				if (alloc != ALLOC_ANYWHERE) {
+					/* Don't allocate onto the log pv */
+					if (ah->log_area_count)
+						dm_list_iterate_items(aa, &ah->alloced_areas[ah->area_count])
+							for (s = 0; s < ah->log_area_count; s++)
+								if (!aa[s].pv)
+									goto next_pv;
+
+					/* Avoid PVs used by existing parallel areas */
+					if (parallel_pvs)
+						dm_list_iterate_items(pvl, parallel_pvs)
+							if (pvm->pv == pvl->pv)
 								goto next_pv;
+				}
 
-				/* Avoid PVs used by existing parallel areas */
-				if (parallel_pvs)
-					dm_list_iterate_items(pvl, parallel_pvs)
-						if (pvm->pv == pvl->pv)
+				already_found_one = 0;
+				/* First area in each list is the largest */
+				dm_list_iterate_items(pva, &pvm->areas) {
+					/* Skip fully-reserved areas (which are not currently removed from the list). */
+					if (!pva->unreserved)
+						continue;
+					if (contiguous) {
+						if (prev_lvseg &&
+						    _check_contiguous(ah->cmd,
+								      prev_lvseg,
+								      pva, *areas_ptr,
+								      *areas_size_ptr)) {
+							preferred_count++;
 							goto next_pv;
-			}
-
-			already_found_one = 0;
-			/* First area in each list is the largest */
-			dm_list_iterate_items(pva, &pvm->areas) {
-				if (contiguous) {
-					if (prev_lvseg &&
-					    _check_contiguous(ah->cmd,
-							      prev_lvseg,
-							      pva, *areas_ptr,
-							      *areas_size_ptr)) {
-						preferred_count++;
-						goto next_pv;
+						}
+						continue;
 					}
-					continue;
-				}
 
-				if (cling) {
-					if (prev_lvseg &&
-					    _check_cling(ah->cmd,
-							   prev_lvseg,
-							   pva, *areas_ptr,
-							   *areas_size_ptr)) {
-						preferred_count++;
+					if (cling) {
+						if (prev_lvseg &&
+						    _check_cling(ah->cmd,
+								   prev_lvseg,
+								   pva, *areas_ptr,
+								   *areas_size_ptr)) {
+							preferred_count++;
+						}
+						goto next_pv;
 					}
-					goto next_pv;
-				}
-
-				/* Is it big enough on its own? */
-				if (pva->count * ah->area_multiple <
-				    max_parallel - *allocated &&
-				    ((!can_split && !ah->log_area_count) ||
-				     (already_found_one &&
-				      !(alloc == ALLOC_ANYWHERE))))
-					goto next_pv;
-
-				/*
-				 * Except with ALLOC_ANYWHERE, replace first area with this
-				 * one which is smaller but still big enough.
-				 */
-				if (!already_found_one ||
-				    alloc == ALLOC_ANYWHERE) {
-					ix++;
-					already_found_one = 1;
-				}
 
-				if (ix + ix_offset - 1 < ah->area_count)
-					required = (max_parallel - *allocated) / ah->area_multiple;
-				else
-					required = ah->log_len;
+					/* Is it big enough on its own? */
+					if (pva->unreserved * ah->area_multiple <
+					    max_parallel - *allocated &&
+					    ((!can_split && !ah->log_area_count) ||
+					     (already_found_one &&
+					      !(alloc == ALLOC_ANYWHERE))))
+						goto next_pv;
 
-				if (required > pva->count)
-					required = pva->count;
+					/*
+					 * Except with ALLOC_ANYWHERE, replace first area with this
+					 * one which is smaller but still big enough.
+					 */
+					if (!already_found_one ||
+					    alloc == ALLOC_ANYWHERE) {
+						ix++;
+						already_found_one = 1;
+					}
 
-				/* Expand areas array if needed after an area was split. */
-				if (ix + ix_offset > *areas_size_ptr) {
-					*areas_size_ptr *= 2;
-					*areas_ptr = dm_realloc(*areas_ptr, sizeof(**areas_ptr) * (*areas_size_ptr));
+					if (ix + ix_offset - 1 < ah->area_count)
+						required = (max_parallel - *allocated) / ah->area_multiple;
+					else
+						required = ah->log_len;
+
+					if (alloc == ALLOC_ANYWHERE) {
+						/*
+						 * Update amount unreserved - effectively splitting an area 
+						 * into two or more parts.  If the whole stripe doesn't fit,
+						 * reduce amount we're looking for.
+						 */
+						if (required >= pva->unreserved) {
+							required = pva->unreserved;
+							pva->unreserved = 0;
+						} else {
+							pva->unreserved -= required;
+							reinsert_reduced_pv_area(pva);
+						}
+					} else if (required > pva->count)
+						required = pva->count;
+
+					/* Expand areas array if needed after an area was split. */
+					if (ix + ix_offset > *areas_size_ptr) {
+						*areas_size_ptr *= 2;
+						*areas_ptr = dm_realloc(*areas_ptr, sizeof(**areas_ptr) * (*areas_size_ptr));
+					}
+					(*areas_ptr)[ix + ix_offset - 1].pva = pva;
+						(*areas_ptr)[ix + ix_offset - 1].used = required;
+					log_debug("Trying allocation area %" PRIu32 " on %s start PE %" PRIu32
+						  " length %" PRIu32 " leaving %" PRIu32 ".",
+						  ix + ix_offset - 1, dev_name(pva->map->pv->dev), pva->start, required,
+						  (alloc == ALLOC_ANYWHERE) ? pva->unreserved : pva->count - required);
 				}
-				(*areas_ptr)[ix + ix_offset - 1].pva = pva;
-				(*areas_ptr)[ix + ix_offset - 1].used = required;
-				log_debug("Trying allocation area %" PRIu32 " on %s start PE %" PRIu32
-					  " length %" PRIu32 " leaving %" PRIu32 ".",
-					  ix + ix_offset - 1, dev_name(pva->map->pv->dev), pva->start, required,
-					  pva->count - required);
+			next_pv:
+				if (ix + ix_offset >= ah->area_count + (log_needs_allocating ? ah->log_area_count : 0))
+					break;
 			}
-		next_pv:
-			if (ix + ix_offset >= ah->area_count + (log_needs_allocating ? ah->log_area_count : 0))
-				break;
-		}
+		} while (alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + (log_needs_allocating ? ah->log_area_count : 0));
 
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
@@ -1211,7 +1237,6 @@
 		if (ix + ix_offset < ah->area_count +
 		    (log_needs_allocating ? ah->log_area_count +
 					    too_small_for_log_count : 0))
-			/* FIXME With ALLOC_ANYWHERE, need to split areas */
 			break;
 
 		if (!_alloc_parallel_area(ah, max_parallel, *areas_ptr, allocated,
--- LVM2/lib/metadata/pv_map.c	2010/03/16 14:37:38	1.35
+++ LVM2/lib/metadata/pv_map.c	2010/03/25 21:19:27	1.36
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
+	uint32_t count = reduced ? a->unreserved : a->count;
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
@@ -50,7 +56,8 @@
 	pva->map = pvm;
 	pva->start = start;
 	pva->count = length;
-	_insert_area(&pvm->areas, pva);
+	pva->unreserved = pva->count;
+	_insert_area(&pvm->areas, pva, 0);
 
 	return 1;
 }
@@ -184,8 +191,7 @@
 
 void consume_pv_area(struct pv_area *pva, uint32_t to_go)
 {
-	dm_list_del(&pva->list);
-	pva->map->pe_count -= pva->count;
+	_remove_area(pva);
 
 	assert(to_go <= pva->count);
 
@@ -193,10 +199,21 @@
 		/* split the area */
 		pva->start += to_go;
 		pva->count -= to_go;
-		_insert_area(&pva->map->areas, pva);
+		pva->unreserved = pva->count;
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
--- LVM2/lib/metadata/pv_map.h	2010/03/25 02:40:09	1.12
+++ LVM2/lib/metadata/pv_map.h	2010/03/25 21:19:27	1.13
@@ -31,6 +31,9 @@
 	uint32_t start;
 	uint32_t count;
 
+	/* Number of extents unreserved during ALLOC_ANYWHERE allocation. */
+	uint32_t unreserved;
+
 	struct dm_list list;		/* pv_map.areas */
 };
 
@@ -66,5 +69,6 @@
 void reinsert_reduced_pv_area(struct pv_area *pva);
 
 uint32_t pv_maps_size(struct dm_list *pvms);
+void reinsert_reduced_pv_area(struct pv_area *pva);
 
 #endif


