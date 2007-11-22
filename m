From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Nov 2007 14:54:36 -0000
Subject: LVM2 lib/metadata/lv_alloc.h lib/metadata/lv_m ...
Message-ID: <20071122145436.14216.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-11-22 14:54:35

Modified files:
	lib/metadata   : lv_alloc.h lv_manip.c 
	tools          : lvconvert.c lvcreate.c 

Log message:
	drop mirrored_pv/mirrored_pe from alloc handle

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161

--- LVM2/lib/metadata/lv_alloc.h	2007/08/22 14:38:17	1.17
+++ LVM2/lib/metadata/lv_alloc.h	2007/11/22 14:54:35	1.18
@@ -48,8 +48,6 @@
                                       uint32_t stripes,
                                       uint32_t mirrors, uint32_t log_count,
 				      uint32_t extents,
-                                      struct physical_volume *mirrored_pv,
-                                      uint32_t mirrored_pe,
                                       struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
 				      struct list *parallel_areas);
--- LVM2/lib/metadata/lv_manip.c	2007/11/12 20:51:53	1.134
+++ LVM2/lib/metadata/lv_manip.c	2007/11/22 14:54:35	1.135
@@ -414,8 +414,6 @@
 	uint32_t log_count;		/* Number of parallel 1-extent logs */
 	uint32_t total_area_len;	/* Total number of parallel extents */
 
-	struct physical_volume *mirrored_pv;	/* FIXME Remove this */
-	uint32_t mirrored_pe;			/* FIXME Remove this */
 	struct list *parallel_areas;	/* PVs to avoid */
 
 	struct alloced_area log_area;	/* Extent used for log */
@@ -441,8 +439,6 @@
 					uint32_t mirrors,
 					uint32_t stripes,
 					uint32_t log_count,
-					struct physical_volume *mirrored_pv,
-					uint32_t mirrored_pe,
 					struct list *parallel_areas)
 {
 	struct alloc_handle *ah;
@@ -453,15 +449,8 @@
 		return NULL;
 	}
 
-	if ((stripes > 1 || mirrors > 1) && mirrored_pv) {
-		log_error("Can't mix striping or mirroring with "
-			  "creation of a mirrored PV yet");
-		return NULL;
-	}
-
-	if (log_count && (stripes > 1 || mirrored_pv)) {
-		log_error("Can't mix striping or pvmove with "
-			  "a mirror log yet.");
+	if (log_count && stripes > 1) {
+		log_error("Can't mix striping with a mirror log yet.");
 		return NULL;
 	}
 
@@ -469,8 +458,6 @@
 		area_count = 0;
 	else if (mirrors > 1)
 		area_count = mirrors;
-	else if (mirrored_pv)
-		area_count = 1;
 	else
 		area_count = stripes;
 
@@ -497,8 +484,6 @@
 	for (s = 0; s < ah->area_count; s++)
 		list_init(&ah->alloced_areas[s]);
 
-	ah->mirrored_pv = mirrored_pv;
-	ah->mirrored_pe = mirrored_pe;
 	ah->parallel_areas = parallel_areas;
 
 	return ah;
@@ -1087,7 +1072,7 @@
 		return 1;
 	}
 
-	if (ah->mirrored_pv || (ah->alloc == ALLOC_CONTIGUOUS))
+	if (ah->alloc == ALLOC_CONTIGUOUS)
 		can_split = 0;
 
 	if (lv && !list_empty(&lv->segments))
@@ -1193,8 +1178,6 @@
 				      uint32_t stripes,
 				      uint32_t mirrors, uint32_t log_count,
 				      uint32_t extents,
-				      struct physical_volume *mirrored_pv,
-				      uint32_t mirrored_pe,
 				      struct list *allocatable_pvs,
 				      alloc_policy_t alloc,
 				      struct list *parallel_areas)
@@ -1220,11 +1203,8 @@
 		alloc = vg->alloc;
 
 	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc, mirrors,
-			       stripes, log_count, mirrored_pv,
-			       mirrored_pe, parallel_areas))) {
-		stack;
-		return NULL;
-	}
+			       stripes, log_count, parallel_areas)))
+		return_NULL;
 
 	if (!segtype_is_virtual(segtype) &&
 	    !_allocate(ah, vg, lv, (lv ? lv->le_count : 0) + extents,
@@ -1427,12 +1407,13 @@
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, status, extents, segtype);
 
+	/* FIXME Temporary restriction during code reorganisation */
+	if (mirrored_pv)
+		alloc = ALLOC_CONTIGUOUS;
+
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors, 0,
-				    extents, mirrored_pv, mirrored_pe,
-				    allocatable_pvs, alloc, NULL))) {
-		stack;
-		return 0;
-	}
+				    extents, allocatable_pvs, alloc, NULL)))
+		return_0;
 
 	if (mirrors < 2) {
 		if (!lv_add_segment(ah, 0, ah->area_count, lv, segtype, stripe_size,
--- LVM2/tools/lvconvert.c	2007/11/15 02:20:03	1.45
+++ LVM2/tools/lvconvert.c	2007/11/22 14:54:35	1.46
@@ -338,9 +338,7 @@
 		if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
 					    1, lp->mirrors - 1,
 					    corelog ? 0U : 1U,
-					    lv->le_count,
-					    NULL, 0, lp->pvh,
-					    lp->alloc,
+					    lv->le_count, lp->pvh, lp->alloc,
 					    parallel_areas)))
 			return_0;
 
@@ -386,9 +384,7 @@
 			}
 
 			if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype, 0,
-						    0, 1, 0,
-						    NULL, 0, lp->pvh,
-						    lp->alloc,
+						    0, 1, 0, lp->pvh, lp->alloc,
 						    parallel_areas))) {
 				stack;
 				return 0;
--- LVM2/tools/lvcreate.c	2007/11/15 02:20:03	1.160
+++ LVM2/tools/lvcreate.c	2007/11/22 14:54:35	1.161
@@ -740,11 +740,8 @@
 
 		if (!(ah = allocate_extents(vg, NULL, lp->segtype, lp->stripes,
 					    lp->mirrors, lp->corelog ? 0U : 1U,
-					    lp->extents, NULL, 0,
-					    pvh, lp->alloc, NULL))) {
-			stack;
-			return 0;
-		}
+					    lp->extents, pvh, lp->alloc, NULL)))
+			return_0;
 
 		lp->region_size = adjusted_mirror_region_size(vg->extent_size,
 							      lp->extents,


