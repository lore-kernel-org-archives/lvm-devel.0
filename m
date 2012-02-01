From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Feb 2012 02:10:47 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20120201021047.31964.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-01 02:10:46

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c pv_map.c pv_map.h 

Log message:
	Track unreserved space for all alloc policies and then permit NORMAL to place
	log and data on same single PV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2248&r2=1.2249
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.354&r2=1.355
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2012/01/31 21:21:53	1.2248
+++ LVM2/WHATS_NEW	2012/02/01 02:10:45	1.2249
@@ -1,5 +1,6 @@
 Version 2.02.90 - 
 ===================================
+  Allow ALLOC_NORMAL to track reserved extents for log and data on same PV.
   Automatically detect whether corosync clvmd needs to use confdb or cmap.
   Fix data% report for thin volume used as origin for non-thin snapshot.
 
--- LVM2/lib/metadata/lv_manip.c	2012/01/26 21:39:32	1.354
+++ LVM2/lib/metadata/lv_manip.c	2012/02/01 02:10:46	1.355
@@ -1458,22 +1458,18 @@
 			     const struct alloc_parms *alloc_parms, struct alloc_state *alloc_state,
 			     unsigned already_found_one, unsigned iteration_count, unsigned log_iteration_count)
 {
-	unsigned s;
-
 	/* Skip fully-reserved areas (which are not currently removed from the list). */
 	if (!pva->unreserved)
 		return NEXT_AREA;
 
-	if (iteration_count + log_iteration_count) {
+	/* FIXME Should this test be removed? */
+	if (iteration_count)
 		/*
-		 * Don't use an area twice.
-		 * Only ALLOC_ANYWHERE currently supports that, by destroying the data structures,
-		 * which is OK because they are not needed again afterwards.
-		 */
+		* Don't use an area twice.
+		*/
 		for (s = 0; s < alloc_state->areas_size; s++)
 			if (alloc_state->areas[s].pva == pva)
 				return NEXT_AREA;
-	}
 
 	/* If maximise_cling is set, perform several checks, otherwise perform exactly one. */
 	if (!iteration_count && !log_iteration_count && alloc_parms->flags & (A_CONTIGUOUS | A_CLING | A_CLING_TO_ALLOCED)) {
@@ -1531,28 +1527,23 @@
 {
 	uint32_t required = max_to_allocate / ah->area_multiple;
 
-	/* FIXME Maintain unreserved all the time, so other policies can split areas too. */
-
+	/*
+	 * Update amount unreserved - effectively splitting an area 
+	 * into two or more parts.  If the whole stripe doesn't fit,
+	 * reduce amount we're looking for.
+	 */
 	if (alloc == ALLOC_ANYWHERE) {
-		/*
-		 * Update amount unreserved - effectively splitting an area 
-		 * into two or more parts.  If the whole stripe doesn't fit,
-		 * reduce amount we're looking for.
-		 */
 		if (ix_pva - 1 >= ah->area_count)
 			required = ah->log_len;
-		if (required >= pva->unreserved) {
-			required = pva->unreserved;
-			pva->unreserved = 0;
-		} else {
-			pva->unreserved -= required;
-			reinsert_reduced_pv_area(pva);
-		}
+	} else if (required < ah->log_len)
+		required = ah->log_len;
+
+	if (required >= pva->unreserved) {
+		required = pva->unreserved;
+		pva->unreserved = 0;
 	} else {
-		if (required < ah->log_len)
-			required = ah->log_len;
-		if (required > pva->count)
-			required = pva->count;
+		pva->unreserved -= required;
+		reinsert_changed_pv_area(pva);
 	}
 
 	return required;
@@ -1576,8 +1567,7 @@
 			alloc_state->areas[s].pva = NULL;
 	}
 
-	_reserve_area(&alloc_state->areas[ix_pva - 1], pva, required, ix_pva, 
-		  (alloc == ALLOC_ANYWHERE) ? pva->unreserved : pva->count - required);
+	_reserve_area(&alloc_state->areas[ix_pva - 1], pva, required, ix_pva, pva->unreserved);
 
 	return 1;
 }
@@ -1590,6 +1580,19 @@
 		alloc_state->areas[s].pva = NULL;
 }
 
+static void _reset_unreserved(struct dm_list *pvms)
+{
+	struct pv_map *pvm;
+	struct pv_area *pva;
+
+	dm_list_iterate_items(pvm, pvms)
+		dm_list_iterate_items(pva, &pvm->areas)
+			if (pva->unreserved != pva->count) {
+				pva->unreserved = pva->count;
+				reinsert_changed_pv_area(pva);
+			}
+}
+
 static void _report_needed_allocation_space(struct alloc_handle *ah,
 					    struct alloc_state *alloc_state)
 {
@@ -1653,6 +1656,7 @@
 			  alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
 
 	_clear_areas(alloc_state);
+	_reset_unreserved(pvms);
 
 	_report_needed_allocation_space(ah, alloc_state);
 
@@ -2590,6 +2594,7 @@
 		log_count = 1;
 	} else if (segtype_is_raid(segtype) && !lv->le_count)
 		log_count = mirrors * stripes;
+	/* FIXME log_count should be 1 for mirrors */
 
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    log_count, region_size, extents,
@@ -4341,6 +4346,7 @@
 		}
 	}
 
+	/* FIXME Log allocation and attachment should have happened inside lv_extend. */
 	if (lp->log_count &&
 	    !seg_is_raid(first_seg(lv)) && seg_is_mirrored(first_seg(lv))) {
 		if (!add_mirror_log(cmd, lv, lp->log_count,
--- LVM2/lib/metadata/pv_map.c	2010/03/25 21:19:27	1.36
+++ LVM2/lib/metadata/pv_map.c	2012/02/01 02:10:46	1.37
@@ -205,10 +205,10 @@
 }
 
 /*
- * Remove an area from list and reinsert it based on its new smaller size
- * after a provisional allocation.
+ * Remove an area from list and reinsert it based on its new size
+ * after a provisional allocation (or reverting one).
  */
-void reinsert_reduced_pv_area(struct pv_area *pva)
+void reinsert_changed_pv_area(struct pv_area *pva)
 {
 	_remove_area(pva);
 	_insert_area(&pva->map->areas, pva, 1);
--- LVM2/lib/metadata/pv_map.h	2010/07/09 15:21:10	1.14
+++ LVM2/lib/metadata/pv_map.h	2012/02/01 02:10:46	1.15
@@ -31,7 +31,7 @@
 	uint32_t start;
 	uint32_t count;
 
-	/* Number of extents unreserved during ALLOC_ANYWHERE allocation. */
+	/* Number of extents unreserved during a single allocation pass. */
 	uint32_t unreserved;
 
 	struct dm_list list;		/* pv_map.areas */
@@ -66,7 +66,7 @@
 			    struct dm_list *allocatable_pvs);
 
 void consume_pv_area(struct pv_area *area, uint32_t to_go);
-void reinsert_reduced_pv_area(struct pv_area *pva);
+void reinsert_changed_pv_area(struct pv_area *pva);
 
 uint32_t pv_maps_size(struct dm_list *pvms);
 


