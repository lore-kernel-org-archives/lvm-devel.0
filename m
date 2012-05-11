From: agk@sourceware.org <agk@sourceware.org>
Date: 11 May 2012 22:53:15 -0000
Subject: LVM2 lib/metadata/lv_manip.c ./WHATS_NEW
Message-ID: <20120511225315.8465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-11 22:53:13

Modified files:
	lib/metadata   : lv_manip.c 
	.              : WHATS_NEW 

Log message:
	Fix cling policy not to behave like normal policy if no previous LV seg.
	Fix alloc cling to cling to PVs already found with contiguous policy.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.379&r2=1.380
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2403&r2=1.2404

--- LVM2/lib/metadata/lv_manip.c	2012/05/11 22:19:12	1.379
+++ LVM2/lib/metadata/lv_manip.c	2012/05/11 22:53:13	1.380
@@ -910,13 +910,18 @@
 	if (alloc_parms->prev_lvseg) {
 		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
 			alloc_parms->flags |= A_CONTIGUOUS_TO_LVSEG;
-		else if (alloc_parms->alloc == ALLOC_CLING)
+		else if ((alloc_parms->alloc == ALLOC_CLING) || (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
 			alloc_parms->flags |= A_CLING_TO_LVSEG;
-		else if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS) {
-			alloc_parms->flags |= A_CLING_TO_LVSEG;
-			alloc_parms->flags |= A_CLING_BY_TAGS;
-		}
-	}
+	} else
+		/*
+		 * A cling allocation that follows a successful contiguous allocation
+		 * must use the same PVs (or else fail).
+		 */
+		if ((alloc_parms->alloc == ALLOC_CLING) || (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
+			alloc_parms->flags |= A_CLING_TO_ALLOCED;
+
+	if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS)
+		alloc_parms->flags |= A_CLING_BY_TAGS;
 
 	/*
 	 * For normal allocations, if any extents have already been found 
@@ -1435,7 +1440,8 @@
 /*
  * Is pva on same PV as any areas already used in this allocation attempt?
  */
-static int _check_cling_to_alloced(struct alloc_handle *ah, struct pv_area *pva, struct alloc_state *alloc_state)
+static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_config_node *cling_tag_list_cn,
+				   struct pv_area *pva, struct alloc_state *alloc_state)
 {
 	unsigned s;
 	struct alloced_area *aa;
@@ -1451,7 +1457,8 @@
 		if (alloc_state->areas[s].pva)
 			continue;	/* Area already assigned */
 		dm_list_iterate_items(aa, &ah->alloced_areas[s]) {
-			if (pva->map->pv == aa[0].pv) {
+			if ((!cling_tag_list_cn && (pva->map->pv == aa[0].pv)) ||
+			    (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pva->map->pv, aa[0].pv))) {
 				_reserve_area(&alloc_state->areas[s], pva, pva->count, s + 1, 0);
 				return 1;
 			}
@@ -1505,29 +1512,28 @@
 		/* Try next area on same PV if looking for contiguous space */
 		if (alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG)
 			return NEXT_AREA;
-	
-		/* Cling_to_alloced? */
-		if ((alloc_parms->flags & A_CLING_TO_ALLOCED) &&
-		    _check_cling_to_alloced(ah, pva, alloc_state))
-			return PREFERRED;
 
-		/* Cling? */
-		if (!(alloc_parms->flags & A_CLING_BY_TAGS) &&
-		    alloc_parms->prev_lvseg && _check_cling(ah, NULL, alloc_parms->prev_lvseg, pva, alloc_state))
+		/* Cling to prev_lvseg? */
+		if (((alloc_parms->flags & A_CLING_TO_LVSEG) || (ah->maximise_cling && alloc_parms->prev_lvseg)) &&
+		    _check_cling(ah, NULL, alloc_parms->prev_lvseg, pva, alloc_state))
 			/* If this PV is suitable, use this first area */
 			return PREFERRED;
 
-		if (!ah->maximise_cling && !(alloc_parms->flags & A_CLING_BY_TAGS))
-			return NEXT_PV;
+		/* Cling_to_alloced? */
+		if ((alloc_parms->flags & A_CLING_TO_ALLOCED) &&
+		    _check_cling_to_alloced(ah, NULL, pva, alloc_state))
+			return PREFERRED;
 
 		/* Cling_by_tags? */
-		if ((alloc_parms->flags & (A_CLING_BY_TAGS | A_CLING_TO_ALLOCED)) && ah->cling_tag_list_cn &&
-		    alloc_parms->prev_lvseg && _check_cling(ah, ah->cling_tag_list_cn, alloc_parms->prev_lvseg, pva, alloc_state))
-			return PREFERRED;
-	
-		if (alloc_parms->flags & A_CLING_BY_TAGS)
+		if (!(alloc_parms->flags & A_CLING_BY_TAGS) || !ah->cling_tag_list_cn)
 			return NEXT_PV;
 
+		if (alloc_parms->prev_lvseg) {
+			if (_check_cling(ah, ah->cling_tag_list_cn, alloc_parms->prev_lvseg, pva, alloc_state))
+				return PREFERRED;
+		} else if (_check_cling_to_alloced(ah, ah->cling_tag_list_cn, pva, alloc_state))
+			return PREFERRED;
+
 		/* All areas on this PV give same result so pointless checking more */
 		return NEXT_PV;
 	}
@@ -1669,6 +1675,7 @@
 	uint32_t devices_needed = ah->area_count + ah->parity_count;
 
 	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
+	/* At most one of A_CONTIGUOUS_TO_LVSEG, A_CLING_TO_LVSEG or A_CLING_TO_ALLOCED may be set */
 	if (alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG))
 		ix_offset = _stripes_per_mimage(alloc_parms->prev_lvseg) * alloc_parms->prev_lvseg->area_count;
 
@@ -1791,7 +1798,7 @@
 				break;
 		}
 	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < devices_needed + alloc_state->log_area_count_still_needed) ||
-		/* With cling_to_alloced, if there were gaps in the preferred areas, have a second iteration */
+		/* With cling_to_alloced and normal, if there were gaps in the preferred areas, have a second iteration */
 		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count &&
 		  (preferred_count < ix_offset || alloc_state->log_area_count_still_needed) &&
 		  (alloc_parms->flags & A_CLING_TO_ALLOCED) && !iteration_count++) ||
@@ -1920,7 +1927,7 @@
 			return_0;
 
 		/*
-		 * If we didn't allocate anything this time and had
+		 * If we didn't allocate anything this time with ALLOC_NORMAL and had
 		 * A_CLING_TO_ALLOCED set, try again without it.
 		 *
 		 * For ALLOC_NORMAL, if we did allocate something without the
@@ -1928,7 +1935,7 @@
 		 * remain on the same disks where possible.
 		 */
 		if (old_allocated == alloc_state->allocated) {
-			if (alloc_parms->flags & A_CLING_TO_ALLOCED)
+			if ((alloc_parms->alloc == ALLOC_NORMAL) && (alloc_parms->flags & A_CLING_TO_ALLOCED))
 				alloc_parms->flags &= ~A_CLING_TO_ALLOCED;
 			else
 				break;	/* Give up */
--- LVM2/WHATS_NEW	2012/05/11 22:19:12	1.2403
+++ LVM2/WHATS_NEW	2012/05/11 22:53:13	1.2404
@@ -1,6 +1,8 @@
 Version 2.02.96 - 
 ================================
-  Fix policy loop not to use later policies when --alloc cling without tags.
+  Fix alloc cling to cling to PVs already found with contiguous policy.
+  Fix cling policy not to behave like normal policy if no previous LV seg.
+  Fix allocation loop not to use later policies when --alloc cling without tags.
   Append _TO_LVSEG to names of internal A_CONTIGUOUS and A_CLING flags.
   Add missing pkg init --with-systemdsystemunitdir in configure.in (2.02.92).
   Fix division by zero if PV with zero PE count is used during vgcfgrestore.


