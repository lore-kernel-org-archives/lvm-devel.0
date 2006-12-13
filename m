From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Dec 2006 03:39:59 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20061213033959.12244.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-13 03:39:59

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata.h 
	tools          : lvconvert.c 

Log message:
	When lvconvert allocates a mirror log, respect parallel area constraints.
	Use loop to iterate through the now-ordered policy list in _allocate().
	Check for failure to allocate just the mirror log.
	Introduce calc_area_multiple().
	Support mirror log allocation when there is only one PV: area_count now 0.
	
	(See lvm-devel list archives for further details.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.519&r2=1.520
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW	2006/12/12 19:30:10	1.519
+++ LVM2/WHATS_NEW	2006/12/13 03:39:57	1.520
@@ -1,5 +1,10 @@
 Version 2.02.17 -
 ===================================
+  When lvconvert allocates a mirror log, respect parallel area constraints.
+  Use loop to iterate through the now-ordered policy list in _allocate().
+  Check for failure to allocate just the mirror log.
+  Introduce calc_area_multiple().
+  Support mirror log allocation when there is only one PV: area_count now 0.
   Fix detection of smallest area in _alloc_parallel_area() for cling policy.
   Add manpage entry for clvmd -T
   Fix gulm operation of clvmd, including a hang when doing lvchange -aey
--- LVM2/lib/metadata/lv_manip.c	2006/12/12 19:30:10	1.113
+++ LVM2/lib/metadata/lv_manip.c	2006/12/13 03:39:58	1.114
@@ -415,6 +415,15 @@
 	struct list alloced_areas[0];	/* Lists of areas in each stripe */
 };
 
+static uint32_t calc_area_multiple(const struct segment_type *segtype,
+				   const uint32_t area_count)
+{
+	if (!segtype_is_striped(segtype) || !area_count)
+		return 1;
+
+	return area_count;
+}
+
 /*
  * Preparation for a specific allocation attempt
  */
@@ -476,7 +485,7 @@
 	ah->area_count = area_count;
 	ah->log_count = log_count;
 	ah->alloc = alloc;
-	ah->area_multiple = segtype_is_striped(segtype) ? ah->area_count : 1;
+	ah->area_multiple = calc_area_multiple(segtype, area_count);
 
 	for (s = 0; s < ah->area_count; s++)
 		list_init(&ah->alloced_areas[s]);
@@ -553,7 +562,7 @@
 	if (mirrored_pv)
 		extra_areas = 1;
 
-	area_multiple = segtype_is_striped(segtype) ? area_count : 1;
+	area_multiple = calc_area_multiple(segtype, area_count);
 
 	/* log_lv gets set up elsehere */
 	if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
@@ -707,7 +716,7 @@
 	if (max_seg_len && *max_seg_len > remaining_seg_len)
 		*max_seg_len = remaining_seg_len;
 
-	area_multiple = segtype_is_striped(seg->segtype) ? seg->area_count : 1;
+	area_multiple = calc_area_multiple(seg->segtype, seg->area_count);
 	area_len = remaining_seg_len / area_multiple ? : 1;
 
 	for (s = first_area;
@@ -1066,6 +1075,7 @@
 	int r = 0;
 	struct list *pvms;
 	uint32_t areas_size;
+	alloc_policy_t alloc;
 
 	if (allocated >= new_extents && !ah->log_count) {
 		log_error("_allocate called with no work to do!");
@@ -1111,50 +1121,18 @@
 		return 0;
 	}
 
-	old_allocated = allocated;
-	if (!_find_parallel_space(ah, ALLOC_CONTIGUOUS, pvms, areas,
-				  areas_size, can_split,
-				  prev_lvseg, &allocated, new_extents)) {
-		stack;
-		goto out;
-	}
-
-	if ((allocated == new_extents) || (ah->alloc == ALLOC_CONTIGUOUS) ||
-	    (!can_split && (allocated != old_allocated)))
-		goto finished;
-
-	old_allocated = allocated;
-	if (!_find_parallel_space(ah, ALLOC_CLING, pvms, areas,
-				  areas_size, can_split,
-				  prev_lvseg, &allocated, new_extents)) {
-		stack;
-		goto out;
-	}
-
-	if ((allocated == new_extents) || (ah->alloc == ALLOC_CLING) ||
-	    (!can_split && (allocated != old_allocated)))
-		goto finished;
-
-	old_allocated = allocated;
-	if (!_find_parallel_space(ah, ALLOC_NORMAL, pvms, areas,
-				  areas_size, can_split,
-				  prev_lvseg, &allocated, new_extents)) {
-		stack;
-		goto out;
-	}
-
-	if ((allocated == new_extents) || (ah->alloc == ALLOC_NORMAL) ||
-	    (!can_split && (allocated != old_allocated)))
-		goto finished;
-
-	if (!_find_parallel_space(ah, ALLOC_ANYWHERE, pvms, areas,
-				  areas_size, can_split,
-				  prev_lvseg, &allocated, new_extents)) {
-		stack;
-		goto out;
+	/* Attempt each defined allocation policy in turn */
+	for (alloc = ALLOC_CONTIGUOUS; alloc < ALLOC_INHERIT; alloc++) {
+		old_allocated = allocated;
+		if (!_find_parallel_space(ah, alloc, pvms, areas,
+					  areas_size, can_split,
+					  prev_lvseg, &allocated, new_extents))
+			goto_out;
+		if ((allocated == new_extents) || (ah->alloc == alloc) ||
+		    (!can_split && (allocated != old_allocated)))
+			break;
 	}
 
-      finished:
 	if (allocated != new_extents) {
 		log_error("Insufficient suitable %sallocatable extents "
 			  "for logical volume %s: %u more required",
@@ -1165,6 +1143,13 @@
 		goto out;
 	}
 
+	if (ah->log_count && !ah->log_area.len) {
+		log_error("Insufficient extents for log allocation "
+			  "for logical volume %s.",
+			  lv ? lv->name : "");
+		goto out;
+	}
+
 	r = 1;
 
       out:
--- LVM2/lib/metadata/metadata.h	2006/11/03 21:07:14	1.151
+++ LVM2/lib/metadata/metadata.h	2006/12/13 03:39:58	1.152
@@ -78,17 +78,18 @@
 #define FMT_RESIZE_PV		0x00000080U	/* Supports pvresize? */
 #define FMT_UNLIMITED_STRIPESIZE 0x00000100U	/* Unlimited stripe size? */
 
+/* Ordered list - see lv_manip.c */
 typedef enum {
-	ALLOC_INVALID = 0,
-	ALLOC_INHERIT,
+	ALLOC_INVALID,
 	ALLOC_CONTIGUOUS,
 	ALLOC_CLING,
 	ALLOC_NORMAL,
-	ALLOC_ANYWHERE
+	ALLOC_ANYWHERE,
+	ALLOC_INHERIT
 } alloc_policy_t;
 
 typedef enum {
-	AREA_UNASSIGNED = 0,
+	AREA_UNASSIGNED,
 	AREA_PV,
 	AREA_LV
 } area_type_t;
--- LVM2/tools/lvconvert.c	2006/11/02 23:33:20	1.23
+++ LVM2/tools/lvconvert.c	2006/12/13 03:39:58	1.24
@@ -281,15 +281,8 @@
 			if (lp->mirrors == existing_mirrors) {
 				if (!seg->log_lv && !arg_count(cmd, corelog_ARG)) {
 					/* No disk log present, add one. */
-					/* FIXME: Why doesn't this work?  Without
-					   it, we will probably put the log on the
-					   same device as a mirror leg.
-					  if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv))) {
-					  stack;
-					  return 0;
-					  }
-					*/
-					parallel_areas = NULL;
+					if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
+						return_0;
 					if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
 						log_error("Unable to determine mirror sync status.");
 						return 0;
@@ -297,7 +290,7 @@
 
 					segtype = get_segtype_from_string(cmd, "striped");
 
-					if (!(ah = allocate_extents(lv->vg, NULL, segtype, 1,
+					if (!(ah = allocate_extents(lv->vg, NULL, segtype, 0,
 								    0, 1, 0,
 								    NULL, 0, 0, lp->pvh,
 								    lp->alloc,


