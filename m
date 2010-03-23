From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Mar 2010 15:07:56 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20100323150756.29815.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-23 15:07:56

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Allow dynamic extension of array of areas selected as allocation candidates.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1474&r2=1.1475
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.210&r2=1.211

--- LVM2/WHATS_NEW	2010/03/23 14:47:35	1.1474
+++ LVM2/WHATS_NEW	2010/03/23 15:07:55	1.1475
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Allow dynamic extension of array of areas selected as allocation candidates.
   Export and use only valid cookie value in test suite.
   Remove const modifier for struct volume_group* from process_each_lv_in_vg().
   Don't allow resizing of internal logical volumes.
--- LVM2/lib/metadata/lv_manip.c	2010/03/01 20:00:21	1.210
+++ LVM2/lib/metadata/lv_manip.c	2010/03/23 15:07:55	1.211
@@ -989,8 +989,8 @@
  * Choose sets of parallel areas to use, respecting any constraints.
  */
 static int _find_parallel_space(struct alloc_handle *ah, alloc_policy_t alloc,
-				struct dm_list *pvms, struct pv_area **areas,
-				uint32_t areas_size, unsigned can_split,
+				struct dm_list *pvms, struct pv_area ***areas_ptr,
+				uint32_t *areas_size_ptr, unsigned can_split,
 				struct lv_segment *prev_lvseg,
 				uint32_t *allocated, uint32_t needed)
 {
@@ -1094,8 +1094,8 @@
 					if (prev_lvseg &&
 					    _check_contiguous(ah->cmd,
 							      prev_lvseg,
-							      pva, areas,
-							      areas_size)) {
+							      pva, *areas_ptr,
+							      *areas_size_ptr)) {
 						preferred_count++;
 						goto next_pv;
 					}
@@ -1106,8 +1106,8 @@
 					if (prev_lvseg &&
 					    _check_cling(ah->cmd,
 							   prev_lvseg,
-							   pva, areas,
-							   areas_size)) {
+							   pva, *areas_ptr,
+							   *areas_size_ptr)) {
 						preferred_count++;
 					}
 					goto next_pv;
@@ -1127,10 +1127,15 @@
 					already_found_one = 1;
 				}
 
-				areas[ix + ix_offset - 1] = pva;
+				/* Expand areas array if needed after an area was split. */
+				if (ix + ix_offset > *areas_size_ptr) {
+					*areas_size_ptr *= 2;
+					*areas_ptr = dm_realloc(*areas_ptr, sizeof(**areas_ptr) * (*areas_size_ptr));
+				}
+				(*areas_ptr)[ix + ix_offset - 1] = pva;
 			}
 		next_pv:
-			if (ix >= areas_size)
+			if (ix >= *areas_size_ptr)
 				break;
 		}
 
@@ -1146,7 +1151,7 @@
 
 		/* sort the areas so we allocate from the biggest */
 		if (ix > 1)
-			qsort(areas + ix_offset, ix, sizeof(*areas),
+			qsort((*areas_ptr) + ix_offset, ix, sizeof(**areas_ptr),
 			      _comp_area);
 
 		/*
@@ -1160,7 +1165,7 @@
 		if (log_needs_allocating) {
 			/* How many areas are too small for the log? */
 			while (too_small_for_log_count < ix_offset + ix &&
-			       (*(areas + ix_offset + ix - 1 -
+			       (*((*areas_ptr) + ix_offset + ix - 1 -
 				  too_small_for_log_count))->count < ah->log_len)
 				too_small_for_log_count++;
 			ix_log_offset = ix_offset + ix - too_small_for_log_count - ah->log_area_count;
@@ -1172,7 +1177,7 @@
 			/* FIXME With ALLOC_ANYWHERE, need to split areas */
 			break;
 
-		if (!_alloc_parallel_area(ah, max_parallel, areas, allocated,
+		if (!_alloc_parallel_area(ah, max_parallel, *areas_ptr, allocated,
 					  log_needs_allocating, ix_log_offset))
 			return_0;
 
@@ -1247,8 +1252,8 @@
 	/* Attempt each defined allocation policy in turn */
 	for (alloc = ALLOC_CONTIGUOUS; alloc < ALLOC_INHERIT; alloc++) {
 		old_allocated = allocated;
-		if (!_find_parallel_space(ah, alloc, pvms, areas,
-					  areas_size, can_split,
+		if (!_find_parallel_space(ah, alloc, pvms, &areas,
+					  &areas_size, can_split,
 					  prev_lvseg, &allocated, ah->new_extents))
 			goto_out;
 		if ((allocated == ah->new_extents) || (ah->alloc == alloc) ||


