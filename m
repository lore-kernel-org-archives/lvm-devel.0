From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 13:58:13 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100401135813.22411.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 13:58:13

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Try to fix tracking of whether or not log extents need allocating.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.222&r2=1.223

--- LVM2/lib/metadata/lv_manip.c	2010/04/01 12:29:07	1.222
+++ LVM2/lib/metadata/lv_manip.c	2010/04/01 13:58:13	1.223
@@ -1011,7 +1011,7 @@
 				struct dm_list *pvms, struct pv_area_used **areas_ptr,
 				uint32_t *areas_size_ptr, unsigned can_split,
 				struct lv_segment *prev_lvseg,
-				uint32_t *allocated, uint32_t needed)
+				uint32_t *allocated, uint32_t *log_needs_allocating, uint32_t needed)
 {
 	struct pv_map *pvm;
 	struct pv_area *pva;
@@ -1028,7 +1028,6 @@
 	struct seg_pvs *spvs;
 	struct dm_list *parallel_pvs;
 	uint32_t free_pes;
-	unsigned log_needs_allocating;
 	struct alloced_area *aa;
 	uint32_t s;
 
@@ -1082,9 +1081,6 @@
 			}
 		}
 
-		log_needs_allocating = (ah->log_area_count &&
-					dm_list_empty(&ah->alloced_areas[ah->area_count])) ?  1 : 0;
-
 		do {
 			/*
 			 * Provide for escape from the loop if no progress is made.
@@ -1183,8 +1179,12 @@
 							pva->unreserved -= required;
 							reinsert_reduced_pv_area(pva);
 						}
-					} else if (required > pva->count)
-						required = pva->count;
+					} else {
+						if (required < ah->log_len)
+							required = ah->log_len;
+						if (required > pva->count)
+							required = pva->count;
+					}
 
 					/* Expand areas array if needed after an area was split. */
 					if (ix + ix_offset > *areas_size_ptr) {
@@ -1200,16 +1200,16 @@
 				}
 			next_pv:
 				if (alloc == ALLOC_ANYWHERE &&
-				    ix + ix_offset >= ah->area_count + (log_needs_allocating ? ah->log_area_count : 0))
+				    ix + ix_offset >= ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0))
 					break;
 			}
-		} while (alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + (log_needs_allocating ? ah->log_area_count : 0));
+		} while (alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0));
 
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
 
 		if (ix + ix_offset < ah->area_count +
-		   (log_needs_allocating ? ah->log_area_count : 0))
+		   (*log_needs_allocating ? ah->log_area_count : 0))
 			break;
 
 		/* sort the areas so we allocate from the biggest */
@@ -1225,7 +1225,7 @@
 		ix_log_offset = 0;
 
 		/* FIXME This logic is due to its heritage and can be simplified! */
-		if (log_needs_allocating) {
+		if (*log_needs_allocating) {
 			/* How many areas are too small for the log? */
 			while (too_small_for_log_count < ix_offset + ix &&
 			       (*((*areas_ptr) + ix_offset + ix - 1 -
@@ -1235,14 +1235,16 @@
 		}
 
 		if (ix + ix_offset < ah->area_count +
-		    (log_needs_allocating ? ah->log_area_count +
+		    (*log_needs_allocating ? ah->log_area_count +
 					    too_small_for_log_count : 0))
 			break;
 
 		if (!_alloc_parallel_area(ah, max_parallel, *areas_ptr, allocated,
-					  log_needs_allocating, ix_log_offset))
+					  *log_needs_allocating, ix_log_offset))
 			return_0;
 
+		*log_needs_allocating = 0;
+
 	} while ((alloc != ALLOC_CONTIGUOUS) && *allocated != needed && can_split);
 
 	return 1;
@@ -1268,15 +1270,15 @@
 	uint32_t areas_size;
 	alloc_policy_t alloc;
 	struct alloced_area *aa;
-	unsigned log_allocated = 0;
+	unsigned log_needs_allocating = 0;
 
 	if (allocated >= ah->new_extents && !ah->log_area_count) {
 		log_error("_allocate called with no work to do!");
 		return 1;
 	}
 
-	if (!ah->log_area_count)
-		log_allocated = 1;
+	if (ah->log_area_count)
+		log_needs_allocating = 1;
 
 	if (ah->alloc == ALLOC_CONTIGUOUS)
 		can_split = 0;
@@ -1322,17 +1324,14 @@
 			  "Need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log extents.",
 			  get_alloc_string(alloc),
 			  (ah->new_extents - allocated) / ah->area_multiple,
-			  ah->area_count, log_allocated ? 0 : ah->log_area_count);
+			  ah->area_count, log_needs_allocating ? ah->log_area_count : 0);
 		if (!_find_parallel_space(ah, alloc, pvms, &areas,
 					  &areas_size, can_split,
-					  prev_lvseg, &allocated, ah->new_extents))
+					  prev_lvseg, &allocated, &log_needs_allocating, ah->new_extents))
 			goto_out;
-		if ((allocated == ah->new_extents) || (ah->alloc == alloc) ||
+		if ((allocated == ah->new_extents && !log_needs_allocating) || (ah->alloc == alloc) ||
 		    (!can_split && (allocated != old_allocated)))
 			break;
-		/* Log is always allocated the first time anything is allocated. */
-		if (old_allocated != allocated)
-			log_allocated = 1;
 	}
 
 	if (allocated != ah->new_extents) {
@@ -1345,14 +1344,12 @@
 		goto out;
 	}
 
-	if (ah->log_area_count)
-		dm_list_iterate_items(aa, &ah->alloced_areas[ah->area_count])
-			if (!aa[0].pv) {
-				log_error("Insufficient extents for log allocation "
-					  "for logical volume %s.",
-					  lv ? lv->name : "");
-				goto out;
-			}
+	if (log_needs_allocating) {
+		log_error("Insufficient extents for log allocation "
+			  "for logical volume %s.",
+			  lv ? lv->name : "");
+		goto out;
+	}
 
 	r = 1;
 


